extends Control 

signal lever_state_changed(is_down: bool)

var is_dragging: bool = false
var min_y: float = 0.0
var max_y: float = 120.0 
var is_currently_down: bool = false 

@export var lever_bars: Control

func _ready() -> void:
	min_y = position.y
	max_y = min_y + 120.0 
	

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_dragging = event.pressed
		if not is_dragging:
			if is_currently_down:
				is_currently_down = false
				lever_state_changed.emit(false)

func _process(delta: float) -> void:
	if is_dragging:
		var target_y = get_parent().get_local_mouse_position().y - (size.y / 2.0)
		position.y = clamp(target_y, min_y, max_y)
		
		var is_down_now = (position.y >= max_y - 10)
		if is_down_now != is_currently_down:
			is_currently_down = is_down_now
			lever_state_changed.emit(is_currently_down)
	else:
		position.y = lerpf(position.y, min_y, 15.0 * delta)
		
	if lever_bars:
		var progress = (position.y - min_y) / (max_y - min_y)
		var nueva_escala_y = 1.0 - (progress * 2.0)
		lever_bars.scale.y = nueva_escala_y
