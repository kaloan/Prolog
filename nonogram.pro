?-
	G_X:=7,
	G_Y:=5,
	G_CellSize:=30,
	G_ScreenWidthPadding:=200,
	G_ScreenHeightPadding:=200,

	G_Density:=0.4, 
	array(data, G_X*G_Y, 0),
	array(solution, G_X*G_Y, 0),
	init_solution,
	window(title("Nonogram"), size(G_ScreenWidthPadding+G_CellSize*G_X, G_ScreenHeightPadding+G_CellSize*G_Y)).

win_func(mouse_click(X, Y)):-
	write(X),
	write(" "),
	write(Y),
	write("\n"),
	J := X // G_CellSize,
	I := Y // G_CellSize,
	write(I),
	write(" "),
	write(J),
	write("\n"),
	write(data(G_X*I+J)),
	write("\n"),
	data(G_X*I+J) := 1 - data(G_X*I+J),
	write(data(G_X*I+J)),
	write("\n"),
	update_window(_).

win_func(paint):-
	for(I, 0, G_Y-1),
		for(J, 0, G_X-1),
			make_brush(I, J),
			rect(G_CellSize*J, G_CellSize*I, G_CellSize*(J+1), G_CellSize*(I+1)),
	fail.

make_brush(I, J):-
	(solution(G_X*I+J)=:=0	->
		brush(rgb(255,255,255))
	else
		brush(rgb(255,0,0))
	).



init_solution:-
	for(I, 0, G_Y-1),
		for(J, 0, G_X-1),
			(random(100)/100 < G_Density ->
				solution(G_X*I+J):=1
			),
	fail.
init_solution.