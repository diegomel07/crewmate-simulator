# res://scenes/minigames/chart_course/PathLine.gd
class_name PathLine
extends Control

@export var dash_length: float = 10.0
@export var gap_length: float = 6.0
@export var line_color: Color = Color(0.1, 0.15, 0.25, 0.8)
@export var line_width: float = 3.0

var points: Array[Vector2] = []


func set_points(new_points: Array[Vector2]) -> void:
	points = new_points
	queue_redraw()


func _draw() -> void:
	if points.size() < 2:
		return
	for i in points.size() - 1:
		_draw_dashed_segment(points[i], points[i + 1])


func _draw_dashed_segment(from: Vector2, to: Vector2) -> void:
	var total_dist: float = from.distance_to(to)
	var dir: Vector2 = (to - from).normalized()
	var traveled: float = 0.0
	var is_dash: bool = true

	while traveled < total_dist:
		var seg_len: float = dash_length if is_dash else gap_length
		var next_traveled: float = min(traveled + seg_len, total_dist)

		if is_dash:
			draw_line(from + dir * traveled, from + dir * next_traveled, line_color, line_width)

		traveled = next_traveled
		is_dash = not is_dash
