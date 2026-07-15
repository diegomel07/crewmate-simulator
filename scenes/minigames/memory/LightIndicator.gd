# res://scenes/minigames/memory/LightIndicator.gd
class_name LightIndicator
extends Control

@export var off_color: Color = Color(0.35, 0.35, 0.35)
@export var on_color: Color = Color(0.2, 0.9, 0.3)

@onready var art: Node = $LightArt   # TODO: puede ser ColorRect o Sprite2D


func _ready() -> void:
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER   # <- esto es lo que faltaba
	size_flags_vertical = Control.SIZE_SHRINK_CENTER     # <- y esto
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	custom_minimum_size = Vector2(24, 24)
	size = custom_minimum_size

	if art is Control:
		art.set_anchors_preset(Control.PRESET_FULL_RECT)
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE

	set_on(false)

func set_on(value: bool) -> void:
	var color: Color = on_color if value else off_color
	if art is ColorRect:
		art.color = color
	elif art is CanvasItem:
		art.modulate = color
