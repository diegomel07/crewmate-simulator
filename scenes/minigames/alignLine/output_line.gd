# res://scenes/minigames/align_line/OutputLine.gd
extends Control

func _draw() -> void:
	draw_line(Vector2(0, size.y / 2.0), Vector2(size.x, size.y / 2.0), Color.RED, 3.0)
