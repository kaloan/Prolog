?-
	G_X:=12,
	G_Y:=12,
	G_CellSize:=30,
	G_ScreenWidthPadding:=200,
	G_ScreenHeightPadding:=200,
	
	G_ColorExploaded:=rgb(255,125,0),
	G_ColourUnopened:=rgb(180,180,180),
	G_ColourOpened:=rgb(255,255,255),
	G_ColourTagged:=rgb(255,0,255),
	G_MineNum:=9,
	G_MineCount:=0,	
	G_TaggedCount:=0,
	
	G_DensityBase:=0.15,
	G_Density:=G_DensityBase * (1 + 1.0/((G_X*G_Y) - 1)),
	%G_Density:=G_DensityBase,
	G_TextTranslate:=0.17,
	
	G_OpenedCount:=0,
	G_GameOver:=0,
	
	array(minefield, G_X*G_Y, 0),
	array(opened, G_X*G_Y, 0),
	array(tagged,G_X*G_Y, 0),
	pen(1,rgb(0,0,0)),
	window(title("Minesweeper"), size(G_ScreenWidthPadding+G_CellSize*G_X, G_ScreenHeightPadding+G_CellSize*G_Y)).

win_func(key_down(CharCode, Repetition)):-
	write(CharCode).

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
	
	(I =< G_Y, J =< G_X, G_GameOver=:=0 ->

		(G_OpenedCount =:= 0 ->
			write("INININ"),
			init_minefield(I,J)
		),
		
	
		(opened(G_X*I+J) =:= 0 ->  
			%opened(G_X*I+J):= 1,
			%G_OpenedCount:=G_OpenedCount+1
			open_recursive(I, J)
		),
		write(opened(G_X*I+J)),
		write(" "),
		write(minefield(G_X*I+J)),
		write(" "),
	
		update_window(_),

		(minefield(G_X*I+J) =:= G_MineNum ->  
			%Stop program - game lost%
			
			G_GameOver:=1
		),
		(G_OpenedCount =:= G_X*G_Y-G_MineCount ->  
			%Stop program - game won, only mines remain%
			%text_out("GAME WON!", pos(G_CellSize*G_X+G_ScreenWidthPadding//2, G_ScreenHeightPadding//2+G_CellSize*G_Y)),
			G_GameOver:=2
		)
	).
win_func(r_mouse_click(X, Y)):-
	write(X),
	write(" "),
	write(Y),
	write("\n"),

	J := X // G_CellSize,
	I := Y // G_CellSize,
	(I =< G_Y, J =< G_X, G_GameOver=:=0, opened(G_X*I+J) =:= 0 ->  
		tagged(G_X*I+J):=1-tagged(G_X*I+J),
		(tagged(G_X*I+J)=:=1 ->
			G_TaggedCount:=G_TaggedCount+1
		else
			G_TaggedCount:=G_TaggedCount-1
		)
	),
	update_window(_).


win_func(paint):-
	(G_GameOver=:=1 -> text_out("YOU HIT A MINE!", pos(G_ScreenWidthPadding//4, G_ScreenHeightPadding//2+G_CellSize*G_Y))),
	(G_GameOver=:=2 -> text_out("GAME WON!", pos(G_ScreenWidthPadding//4, G_ScreenHeightPadding//2+G_CellSize*G_Y))),
	text_out("Mines left:" + (G_MineCount - G_TaggedCount) , pos(0, G_CellSize*G_Y)),
	for(I, 0, G_Y-1),
		for(J, 0, G_X-1),
			make_cell(I, J),
	fail.



open_recursive(I, J):-
	(opened(G_X*I+J) =:= 0 ->
		opened(G_X*I+J):= 1,
		G_OpenedCount:=G_OpenedCount+1,
		(minefield(G_X*I+J)=:=0 ->
			for(K,-1,1),
				for(T,-1,1),
					(in_field(I+K,J+T) -> open_recursive(I+K,J+T))
		), fail
	).
open_recursive(_,_).


make_cell(I, J):-
	%text_out("Mines left:" + G_MineCount - G_TaggedCount , pos(0, G_ScreenHeightPadding//2+G_CellSize*G_Y)),
	(opened(G_X*I+J) =:= 1 ->
		(minefield(G_X*I+J) =\= G_MineNum ->
			brush(G_ColourOpened),
			rect(G_CellSize*J, G_CellSize*I, G_CellSize*(J+1), G_CellSize*(I+1)),
			(minefield(G_X*I+J) =\= 0 ->
				text_out(minefield(G_X*I+J) , pos(G_CellSize*(J + 0.5 - G_TextTranslate), G_CellSize*(I + 0.5 - G_TextTranslate)))
			)
	
		else
			brush(G_ColorExploaded),
			rect(G_CellSize*J, G_CellSize*I, G_CellSize*(J+1), G_CellSize*(I+1)),
			text_out("X", pos(G_CellSize*(J + 0.5 - G_TextTranslate), G_CellSize*(I + 0.5 - G_TextTranslate)))
		)
	else
		(tagged(G_X*I+J)=:=0 ->
			brush(G_ColourUnopened),
			rect(G_CellSize*J, G_CellSize*I, G_CellSize*(J+1), G_CellSize*(I+1))
		else
			brush(G_ColourTagged),
			rect(G_CellSize*J, G_CellSize*I, G_CellSize*(J+1), G_CellSize*(I+1))
		)
	).



init_minefield(SX,SY):-
	for(I, 0, G_Y-1),
		for(J, 0, G_X-1),
			(I=\=SX, J=\=SY ->
				(random(100)/100 < G_Density ->
					minefield(G_X*I+J):=G_MineNum,
					G_MineCount:=G_MineCount+1,
					for(K,-1,1),
						for(T,-1,1),
							(in_field(I+K,J+T),minefield(G_X*(I+K)+J+T) < 8 ->
						 		minefield(G_X*(I+K)+J+T):=minefield(G_X*(I+K)+J+T)+1
							)	
				)
			),
	fail.
init_minefield(_,_).

in_field(I,J):-
	I>=0,I<G_Y,J>=0,J<G_X.
