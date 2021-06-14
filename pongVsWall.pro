?-
G_Refresh_Time := 0.01,
G_Time := 0,
G_Pause:=0, %whether the game is paused
G_Gravitational_Acceleration:=0.1, %acceleration due to gravity
G_Missed_Balls := 0,

G_Wall_X:=10,
G_Floor_Y:=500,
G_Ceiling_Y:=10,

G_Racket_X=900, % X coord of the racket line
G_Racket_Y:=400, % Y coord of racket top
G_Racket_Speed_Max:=8, %maximum racket speed
G_Racket_Speed:=G_Racket_Speed_Max, %initial racket speed
G_Racket_Slow_Movement_Coeff:=0.2,
G_Racket_Length:=50, %racket length
new_ball, %spawn ball
window(title("Pong"), size(1000, 550),paint_indirectly).

win_func(paint):-
	text_out("Balls: " + G_Missed_Balls + ", time=" + G_Time, pos(20, 20)),
	text_out("Seconds per balls : " + G_Time/(G_Missed_Balls + 1) , pos(20, 40)),
	line(G_Racket_X, G_Racket_Y, G_Racket_X, G_Racket_Y + G_Racket_Length),
	line(G_Racket_X, G_Ceiling_Y, G_Wall_X, G_Wall_X, G_Wall_X, G_Floor_Y, G_Racket_X, G_Floor_Y),
	ellipse(G_X-G_Ball_Radius, G_Y-G_Ball_Radius, G_X+G_Ball_Radius, G_Y+G_Ball_Radius).

win_func(init):-
	_:=set_timer(_, G_Refresh_Time, time_func).

%win_func(key_down(CharCode, Repetition)):-
%	write(CharCode).

%win_func(key_down(38, Repetition)):- %move up
%	G_Racket_Speed:= -1*G_Racket_Speed_Max.

%win_func(key_down(40, Repetition)):- %move down
%	G_Racket_Speed:= G_Racket_Speed_Max.

win_func(key_down(38, Repetition)):- %move up
	(G_Racket_Speed > -1*G_Racket_Slow_Movement_Coeff * G_Racket_Speed_Max ->
		G_Racket_Speed := -1*G_Racket_Slow_Movement_Coeff * G_Racket_Speed_Max
	else
		G_Racket_Speed := -1*G_Racket_Speed_Max
	).

win_func(key_down(40, Repetition)):- %move down
	(G_Racket_Speed < G_Racket_Slow_Movement_Coeff * G_Racket_Speed_Max ->
		G_Racket_Speed := G_Racket_Slow_Movement_Coeff * G_Racket_Speed_Max
	else
		G_Racket_Speed := G_Racket_Speed_Max
	).



win_func(key_down(80, Repetition)):- %pause
	G_Pause:= 1-G_Pause.


time_func(end):-
	G_Pause =:= 0, %if not paused
	
	G_Time := G_Time + G_Refresh_Time,
	G_X:=G_X+G_Speed_X, %new ball coords
	G_Y:=G_Y+G_Speed_Y,
	G_Speed_Y:=G_Speed_Y + G_Gravitational_Acceleration + G_Spin, %new ball speed
	G_Spin := 0.95 * G_Spin,
	G_Racket_Y:=G_Racket_Y + G_Racket_Speed,
	(G_Racket_Y > G_Floor_Y - G_Racket_Length, G_Racket_Speed > 0 -> G_Racket_Speed := 0),
	(G_Racket_Y < G_Ceiling_Y, G_Racket_Speed < 0 -> G_Racket_Speed := 0),
	%if ball hits left wall
	(G_X - G_Ball_Radius < G_Wall_X -> G_Speed_X:= -1 * G_Speed_X), 
	%if ball hits ceiling
	(G_Y - G_Ball_Radius < G_Ceiling_Y -> G_Speed_Y:= -1 * G_Speed_Y),
	%if ball is hit
	(G_Y + G_Ball_Radius > 500 -> 
		G_Speed_Y:= -1*G_Speed_Y
	),
	%if ball is missed
	(G_X + G_Ball_Radius > G_Racket_X-> 
		check_racket()
	),
	update_window(_).

check_racket():-
	( G_Y + G_Ball_Radius > G_Racket_Y, G_Y + G_Ball_Radius < G_Racket_Y + G_Racket_Length -> 
		G_Speed_X:= -1*G_Speed_X,
		G_Spin := G_Racket_Speed/G_Ball_Radius
	else
		wait(1),
		G_Missed_Balls := G_Missed_Balls + 1,
		new_ball
	).

new_ball:-
	G_X:= 150 + random(100), %ball X
	G_Y:= 150 + random(100),	%ball Y
	G_Speed_X:=3, %ball X speed
	G_Speed_Y:=3,	%ball Y speed
	G_Ball_Radius:=5, %the ball radius
	G_Spin = 0.
	