# res://scenes/minigames/clear_asteroids/TargetAreaArt.gd
# Colgar este script del nodo "TargetAreaArt" (hijo de "TargetArea").
# TargetArea y TargetAreaArt deben ocupar todo el rect del minijuego
# (anchors full rect), e ir POR ENCIMA de la capa de asteroides en el árbol
# para que se dibuje encima, pero con mouse_filter = IGNORE para no tapar
# los clicks sobre los asteroides.
extends Control

@export var line_color: Color = Color(0.6, 1.0, 0.6, 0.55)
@export var line_width: float = 2.0
@export var reticle_color: Color = Color(0.75, 1.0, 0.75, 0.9)
@export var reticle_size: float = 26.0
@export var reticle_gap: float = 8.0     # espacio hueco en el centro de la cruz
@export var hide_system_cursor: bool = true

var _mouse_pos: Vector2 = Vector2.ZERO


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if hide_system_cursor:
		Input.set_default_cursor_shape(Input.CURSOR_CROSS)


func _process(_delta: float) -> void:
	_mouse_pos = get_local_mouse_position()
	queue_redraw()


func _draw() -> void:
	var rect_size: Vector2 = size

	# Líneas que convergen desde las esquinas inferiores hacia la mira,
	# como en la tarea de "Clear Asteroids" de Among Us.
	var bottom_left := Vector2(0.0, rect_size.y)
	var bottom_right := Vector2(rect_size.x, rect_size.y)

	draw_line(bottom_left, _mouse_pos, line_color, line_width, true)
	draw_line(bottom_right, _mouse_pos, line_color, line_width, true)

	_draw_reticle(_mouse_pos)


func _draw_reticle(pos: Vector2) -> void:
	var s := reticle_size * 0.5
	var g := reticle_gap

	# Marco cuadrado
	var rect := Rect2(pos - Vector2(s, s), Vector2(s, s) * 2.0)
	draw_rect(rect, reticle_color, false, line_width)

	# Cruz central, con hueco en el medio (look de mira táctica)
	draw_line(pos - Vector2(s, 0), pos - Vector2(g, 0), reticle_color, line_width, true)
	draw_line(pos + Vector2(g, 0), pos + Vector2(s, 0), reticle_color, line_width, true)
	draw_line(pos - Vector2(0, s), pos - Vector2(0, g), reticle_color, line_width, true)
	draw_line(pos + Vector2(0, g), pos + Vector2(0, s), reticle_color, line_width, true)


func _exit_tree() -> void:
	if hide_system_cursor:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
