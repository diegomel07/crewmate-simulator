# res://scenes/minigames/memory/GridButton.gd
class_name GridButton
extends Control

signal button_pressed(index: int)

@export var index: int = 0
@export var interactive: bool = true   # false = solo visual, usado en DisplayGrid
@export var idle_color: Color = Color(0.8, 0.8, 0.82)
@export var highlight_color: Color = Color(0.25, 0.55, 0.95)
@export var hide_when_idle: bool = false   # true = invisible en reposo, solo se ve al flashear (pantalla izquierda)

@onready var art: Node = $ButtonArt   # TODO: tu arte acá (ColorRect / Sprite2D / TextureRect)

var is_locked: bool = false   # true mientras se reproduce la secuencia (no se puede clickear)


func _ready() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	custom_minimum_size = Vector2(70, 70)   # tamaño MÍNIMO, no fijo

	# esto es lo que hace que ocupe todo el espacio de su celda en el GridContainer
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	# si no es interactivo (mini-grilla de la pantalla), no bloqueamos clicks
	# de nada porque no hace falta que reciba input
	mouse_filter = Control.MOUSE_FILTER_STOP if interactive else Control.MOUSE_FILTER_IGNORE

	if art is Control:
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		art.set_anchors_preset(Control.PRESET_FULL_RECT)
		# si es TextureRect, que la textura se escale a la celda y no al revés
		if art is TextureRect:
			art.stretch_mode = TextureRect.STRETCH_SCALE
			art.custom_minimum_size = Vector2.ZERO
	else:
		push_warning("GridButton: 'ButtonArt' no es un Control (es %s). Convertilo a TextureRect/ColorRect dentro de un Control, si no, va a ignorar el tamaño de la celda y se va a ver más grande/desalineado." % art.get_class())

	set_highlighted(false)


func set_highlighted(value: bool) -> void:
	if not value and hide_when_idle:
		modulate.a = 0.0    # en reposo: invisible, no se ve el cuadrado
		return

	modulate.a = 1.0
	var color: Color = highlight_color if value else idle_color
	if art is ColorRect:
		art.color = color
	elif art is CanvasItem:
		art.modulate = color


func flash(duration: float) -> void:
	set_highlighted(true)
	await get_tree().create_timer(duration, true, false, true).timeout   # timer que respeta pause
	set_highlighted(false)


func _gui_input(event: InputEvent) -> void:
	if not interactive or is_locked:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			button_pressed.emit(index)
