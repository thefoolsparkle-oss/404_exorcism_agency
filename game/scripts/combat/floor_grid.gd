extends Node2D

var grid_size: float = 120.0
var line_width: float = 1.5
var line_color: Color = Color(0.75, 0.73, 0.7, 0.6)

func _draw() -> void:
	var cols: int = ceil(3840.0 / grid_size) + 1
	var rows: int = ceil(2160.0 / grid_size) + 1
	for x in range(cols):
		draw_line(Vector2(x * grid_size, 0), Vector2(x * grid_size, rows * grid_size), line_color, line_width)
	for y in range(rows):
		draw_line(Vector2(0, y * grid_size), Vector2(cols * grid_size, y * grid_size), line_color, line_width)
