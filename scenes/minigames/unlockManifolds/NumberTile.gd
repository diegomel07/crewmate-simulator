# res://scenes/minigames/unlock_manifolds/NumberTile.gd
class_name NumberTile
extends Control

signal tile_pressed(value: int)

@export var value: int = 1
@export var idle_color: Color = Color(0.55, 0.62, 0.85)
@export var correct_color: Color = Color(0.55, 0.85, 0.35)

@onready var art: Node = $TileArt          # TODO: tu arte acá (ColorRect / Sprite2D / TextureRect)
@onready var number_label: Label = $NumberLabel

var is_correct: bool = false
var is_locked: bool = false   # se usa mientras el teclado está "congelado" en el flash rojo


func _ready() -> void:
	custom_minimum_size = Vector2(90, 90)
	mouse_filter = Control.MOUSE_FILTER_STOP

	if art is Control:
		art.set_anchors_preset(Control.PRESET_FULL_RECT)
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if number_label:
		number_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		number_label.text = str(value)
		number_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		number_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		number_label.set_anchors_preset(Control.PRESET_FULL_RECT)

	set_correct(false)


func set_correct(value_flag: bool) -> void:
	is_correct = value_flag
	var color: Color = correct_color if is_correct else idle_color
	if art is ColorRect:
		art.color = color
	elif art is CanvasItem:
		art.modulate = color


func reset() -> void:
	set_correct(false)


func _gui_input(event: InputEvent) -> void:
	if is_locked or is_correct:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			tile_pressed.emit(value)
