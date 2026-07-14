class_name WireEndpoint
extends Control

signal endpoint_clicked(endpoint: WireEndpoint)

@export var radius: float = 22.0

@onready var art: Node = $EndpointArt   # ahora puede ser Sprite2D

var color: Color = Color.WHITE:
	set(value):
		color = value
		if art:
			art.modulate = value


func _ready() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)   # <- esto es lo que faltaba
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(radius * 2, radius * 2)
	size = custom_minimum_size
	if art is Node2D:
		art.position = size / 2.0


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			endpoint_clicked.emit(self)


func get_center_global() -> Vector2:
	return global_position + size / 2.0
