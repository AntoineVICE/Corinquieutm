@tool
extends Node2D

@export var exterior: bool = false

func _draw() -> void:
	if exterior:
		draw_rect(Rect2(0,0,1600,720),Color("b6bbb0"))
		draw_rect(Rect2(0,195,1600,340),Color("a49b84"))
		draw_colored_polygon(PackedVector2Array([Vector2(0,200),Vector2(800,75),Vector2(1600,200)]),Color("5f6b61"))
		for x in range(180,1600,230):
			draw_rect(Rect2(x,260,118,275),Color("636b5d"))
			draw_arc(Vector2(x+59,265),59,PI,TAU,24,Color("d5c9aa"),18)
			draw_rect(Rect2(x-8,265,15,270),Color("d5c9aa"))
			draw_rect(Rect2(x+111,265,15,270),Color("d5c9aa"))
		draw_rect(Rect2(0,535,1600,185),Color("878a74"))
	else:
		draw_rect(Rect2(0,0,1600,720),Color("b7a88d"))
		draw_rect(Rect2(0,0,1600,155),Color("5f5648"))
		for x in range(70,1600,260):
			draw_rect(Rect2(x,150,20,385),Color("7c6b54"))
		for x in [260,750]:
			draw_rect(Rect2(x,220,110,180),Color("656f66"))
			draw_rect(Rect2(x+10,230,90,160),Color("bec7b1"))
			draw_line(Vector2(x+55,230),Vector2(x+55,390),Color("776d56"),8)
		draw_rect(Rect2(0,535,1600,185),Color("81725a"))
		draw_rect(Rect2(110,470,255,65),Color("625642"))
		draw_rect(Rect2(120,450,235,35),Color("dad0b8"))
		draw_rect(Rect2(210,450,140,38),Color("7e8d81"))
		draw_rect(Rect2(875,475,185,20),Color("70563b"))
		draw_line(Vector2(890,490),Vector2(890,565),Color("614c38"),12)
		draw_line(Vector2(1040,490),Vector2(1040,565),Color("614c38"),12)
		draw_rect(Rect2(945,460,50,12),Color("ece0bf"))
		draw_rect(Rect2(425,510,90,55),Color("69523b"))
		draw_line(Vector2(690,280),Vector2(690,380),Color("584633"),12)
		draw_line(Vector2(660,307),Vector2(720,307),Color("584633"),12)
		draw_rect(Rect2(1390,295,150,240),Color("514f42"))
		draw_rect(Rect2(1400,305,130,230),Color("716953"))
	for y in range(585,720,38):
		draw_line(Vector2(0,y),Vector2(1600,y),Color(0.2,0.2,0.16,0.18),1)
	draw_line(Vector2(0,570),Vector2(1600,570),Color(0.95,0.88,0.68,0.35),2)
