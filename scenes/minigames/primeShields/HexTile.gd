# res://scenes/minigames/prime_shields/HexTile.gd
class_name HexTile
extends Control

signal hex_clicked(tile: HexTile)

@export var hex_radius: float = 42.0   # distancia del centro a cada vértice
@export var is_red: bool = true
@export var red_color: Color = Color(0.75, 0.25, 0.3)
@export var white_color: Color = Color(0.85, 0.85, 0.85)
@export var border_color: Color = Color(0.05, 0.1, 0.25)

var polygon_points: PackedVector2Array = []


func _ready() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	custom_minimum_size = Vector2(hex_radius * 2, hex_radius * 2)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_polygon()


func _build_polygon() -> void:
	polygon_points.clear()
	var center: Vector2 = size / 2.0
	for i in 6:
		# orientación "pointy-top" (vértice arriba), como en la imagen de referencia
		var angle: float = deg_to_rad(60 * i - 90)
		polygon_points.append(center + Vector2(cos(angle), sin(angle)) * hex_radius)


func _draw() -> void:
	var fill_color: Color = red_color if is_red else white_color
	draw_colored_polygon(polygon_points, fill_color)

	var closed_points: PackedVector2Array = polygon_points.duplicate()
	closed_points.append(polygon_points[0])
	draw_polyline(closed_points, border_color, 2.5)


func set_red(value: bool) -> void:
	is_red = value
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if not is_red:
		return

	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			# chequeo preciso: el click tiene que caer DENTRO del hexágono,
			# no solo dentro de la caja cuadrada que lo contiene
			if Geometry2D.is_point_in_polygon(mb.position, polygon_points):
				hex_clicked.emit(self)
