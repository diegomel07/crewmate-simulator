# res://scenes/minigames/align_line/OutputLine.gd
extends Control

@export var color: Color = Color(1, 0, 0) # rojo
@export var thickness: float = 5
@export var dash_length: float = 10
@export var gap_length: float = 5

func _draw() -> void:
	var y: float = size.y / 2.0
	_draw_dashed(Vector2(0, y), Vector2(size.x, y))

func _draw_dashed(from: Vector2, to: Vector2) -> void:
	var total_length: float = from.distance_to(to)
	if total_length <= 0.0:
		return
	var direction: Vector2 = (to - from) / total_length
	var step: float = dash_length + gap_length
	var drawn: float = 0.0
	while drawn < total_length:
		var seg_start: Vector2 = from + direction * drawn
		var seg_end_len: float = min(drawn + dash_length, total_length)
		var seg_end: Vector2 = from + direction * seg_end_len
		draw_line(seg_start, seg_end, color, thickness)
		drawn += step

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()
