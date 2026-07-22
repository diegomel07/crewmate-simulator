# res://scenes/minigames/chart_course/ChartCourseMinigame.gd
class_name ChartCourseMinigame
extends MinigameBase

@export var waypoint_scene: PackedScene = preload("res://scenes/minigames/chartCourse/Waypoint.tscn")
@export var waypoint_count: int = 4
@export var reach_radius: float = 40.0          # qué tan cerca hay que pasar de cada punto
@export var zigzag_low_ratio: float = 0.2       # posición Y del punto "de abajo" (0=arriba, 1=abajo)
@export var zigzag_high_ratio: float = 0.8      # posición Y del punto "de abajo" en el zigzag
@export var side_margin: float = 80.0

@onready var path_line: PathLine = $PathLine
@onready var waypoints_layer: Control = $WaypointsLayer
@onready var ship_icon: Control = $ShipIcon
@onready var feedback_label: Label = $FeedbackLabel

var waypoints: Array[Waypoint] = []
var path_points: Array[Vector2] = []
var ship_start_pos: Vector2
var next_target_index: int = 0
var is_dragging: bool = false


func _on_minigame_ready() -> void:
	call_deferred("_setup_course")


func _setup_course() -> void:
	var rect := get_rect()
	var usable_width: float = rect.size.x - side_margin * 2.0
	var step_x: float = usable_width / float(waypoint_count)

	# --- Ubicamos y preparamos el barco ---
	ship_start_pos = Vector2(side_margin * 0.4, rect.size.y / 2.0)

	ship_icon.set_anchors_preset(Control.PRESET_TOP_LEFT)
	ship_icon.size = Vector2(50, 50)
	ship_icon.position = ship_start_pos - ship_icon.size / 2.0
	ship_icon.mouse_filter = Control.MOUSE_FILTER_STOP
	ship_icon.gui_input.connect(_on_ship_input)

	for child in ship_icon.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# --- Generamos los 4 puntos en zigzag aleatorio ---
	var points_for_line: Array[Vector2] = [ship_start_pos]

	for i in waypoint_count:
		var wp: Waypoint = waypoint_scene.instantiate()
		wp.is_final = (i == waypoint_count - 1)
		waypoints_layer.add_child(wp)

		var x: float = side_margin + step_x * (i + 0.5)
		# alternamos arriba/abajo — el zigzag real de la imagen de referencia
		var y_ratio: float = zigzag_high_ratio if i % 2 == 0 else zigzag_low_ratio
		var y: float = rect.size.y * y_ratio

		wp.position = Vector2(x, y) - wp.size / 2.0

		points_for_line.append(Vector2(x, y))
		waypoints.append(wp)

	path_points = points_for_line
	path_line.set_points(path_points)


func _on_ship_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = mb.pressed

	elif event is InputEventMouseMotion and is_dragging:
		var mm := event as InputEventMouseMotion

		# el mouse "sugiere" hacia dónde moverse, pero el barco se
		# proyecta siempre sobre la línea del camino, como un riel
		var ship_center: Vector2 = ship_icon.position + ship_icon.size / 2.0
		var desired_pos: Vector2 = ship_center + mm.relative
		var projected_pos: Vector2 = _closest_point_on_path(desired_pos)

		ship_icon.position = projected_pos - ship_icon.size / 2.0
		_check_progress()


func _closest_point_on_path(point: Vector2) -> Vector2:
	var best_point: Vector2 = path_points[0]
	var best_dist: float = INF

	for i in path_points.size() - 1:
		var seg_a: Vector2 = path_points[i]
		var seg_b: Vector2 = path_points[i + 1]
		var candidate: Vector2 = Geometry2D.get_closest_point_to_segment(point, seg_a, seg_b)
		var dist: float = point.distance_to(candidate)

		if dist < best_dist:
			best_dist = dist
			best_point = candidate

	return best_point


func _check_progress() -> void:
	if next_target_index >= waypoints.size():
		return

	var ship_center: Vector2 = ship_icon.position + ship_icon.size / 2.0
	var target: Waypoint = waypoints[next_target_index]

	if ship_center.distance_to(target.get_center()) <= reach_radius:
		target.set_reached(true)
		next_target_index += 1
		feedback_label.text = "¡Punto %d alcanzado!" % next_target_index

		if next_target_index >= waypoints.size():
			complete()
