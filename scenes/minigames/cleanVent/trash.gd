extends ColorRect

signal item_cleaned

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

var vent_rect: Control

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_offset = get_global_mouse_position() - global_position
				z_index = 10 
			else:
				is_dragging = false
				z_index = 0
				check_if_cleaned()

func _process(_delta: float) -> void:
	if is_dragging:
		var new_position = get_global_mouse_position() - drag_offset
		var screen_size = get_viewport_rect().size
		new_position.x = clamp(new_position.x, 0, screen_size.x - size.x)
		new_position.y = clamp(new_position.y, 0, screen_size.y - size.y)
		global_position = new_position

func check_if_cleaned() -> void:
	var center = global_position + (size / 2.0)
	if not vent_rect.get_global_rect().has_point(center):
		emit_signal("item_cleaned")
		queue_free()
