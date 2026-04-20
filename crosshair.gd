extends Control

func _draw():
	var center = size / 2
	var length = 10
	var thickness = 2
	var color = Color.WHITE
	
	draw_line(Vector2(center.x - length, center.y), Vector2(center.x + length, center.y), color, thickness)
	draw_line(Vector2(center.x, center.y - length), Vector2(center.x, center.y + length), color, thickness)
