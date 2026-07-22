# res://scenes/minigames/chart_course/Waypoint.gd
class_name Waypoint
extends Control

@export var idle_color: Color = Color(0.85, 0.85, 0.9)
@export var reached_color: Color = Color(0.3, 0.85, 0.4)
@export var is_final: bool = false

@onready var art: Node = $WaypointArt   # TODO: tu arte acá (ColorRect / Sprite2D / TextureRect)


func _ready() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	custom_minimum_size = Vector2(50, 50)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE   # decorativo, no se clickea directamente

	if art is Control:
		art.set_anchors_preset(Control.PRESET_FULL_RECT)
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE

	set_reached(false)


func set_reached(value: bool) -> void:
	var color: Color = reached_color if value else idle_color
	if art is ColorRect:
		art.color = color
	elif art is CanvasItem:
		art.modulate = color


func get_center() -> Vector2:
	return position + size / 2.0
