# res://scenes/minigames/wires/WiresMinigame.gd
class_name WiresMinigame
extends MinigameBase

@export var endpoint_scene: PackedScene = preload("res://scenes/minigames/wires/WireEndpoint.tscn")

@export var wire_colors: Array[Color] = [
	Color.RED,
	Color.BLUE,
	Color.YELLOW,
	Color(1.0, 0.5, 0.0),  # naranja
]

@export var wire_thickness: float = 8.0
@export var margin_top: float = 140.0
@export var margin_bottom: float = 100.0
@export var side_margin: float = 120.0

@onready var lines_layer: Control = $LinesLayer
@onready var left_container: Control = $LeftEndpoints
@onready var right_container: Control = $RightEndpoints
@onready var feedback_label: Label = $FeedbackLabel

var left_endpoints: Array[WireEndpoint] = []
var right_endpoints: Array[WireEndpoint] = []

var correct_pairs: Dictionary = {}     # left_idx -> right_idx correcto
var connections: Dictionary = {}       # left_idx -> right_idx actual

var is_dragging: bool = false
var drag_from_left: int = -1
var drag_current_pos: Vector2 = Vector2.ZERO


func _on_minigame_ready() -> void:
	lines_layer.set_script(preload("res://scenes/minigames/wires/LinesLayer.gd"))
	lines_layer.wires_minigame = self
	call_deferred("_setup_wires")


func _setup_wires() -> void:
	var count := wire_colors.size()
	var rect := get_rect()
	var usable_height := rect.size.y - margin_top - margin_bottom
	var step := usable_height / float(max(count - 1, 1))

	# Mezclamos a qué posición derecha corresponde cada color de la izquierda
	var order := range(count)
	order.shuffle()

	for i in count:
		var y: float = margin_top + step * i

		var left_ep: WireEndpoint = endpoint_scene.instantiate()
		left_container.add_child(left_ep)
		left_ep.position = Vector2(side_margin, y) - left_ep.size / 2.0
		left_ep.color = wire_colors[i]
		left_ep.endpoint_clicked.connect(_on_left_endpoint_clicked.bind(i))
		left_endpoints.append(left_ep)

		var right_ep: WireEndpoint = endpoint_scene.instantiate()
		right_container.add_child(right_ep)
		right_ep.position = Vector2(rect.size.x - side_margin, y) - right_ep.size / 2.0
		right_endpoints.append(right_ep)

		correct_pairs[i] = order[i]

	# Ahora que sabemos el orden, le asignamos el color REAL a cada endpoint derecho
	# (mismo color que el cable izquierdo que le corresponde)
	for left_idx in correct_pairs.keys():
		var right_idx: int = correct_pairs[left_idx]
		right_endpoints[right_idx].color = wire_colors[left_idx]
		right_endpoints[right_idx].endpoint_clicked.connect(_on_right_endpoint_clicked.bind(right_idx))

	lines_layer.queue_redraw()


func _on_left_endpoint_clicked(_endpoint: WireEndpoint, left_idx: int) -> void:
	print("halo")
	# si ya estaba conectado, lo desconectamos para permitir rehacer
	connections.erase(left_idx)
	is_dragging = true
	drag_from_left = left_idx
	drag_current_pos = left_endpoints[left_idx].get_center_global() - global_position
	lines_layer.queue_redraw()


func _on_right_endpoint_clicked(_endpoint: WireEndpoint, right_idx: int) -> void:
	if is_dragging and drag_from_left != -1:
		if not connections.values().has(right_idx):
			connections[drag_from_left] = right_idx
		is_dragging = false
		drag_from_left = -1
		lines_layer.queue_redraw()
		_check_completion()
		return

	# click directo sobre un endpoint derecho ya conectado -> desconectar
	for left_idx in connections.keys():
		if connections[left_idx] == right_idx:
			connections.erase(left_idx)
			lines_layer.queue_redraw()
			break


func _gui_input(event: InputEvent) -> void:
	if is_dragging and event is InputEventMouseMotion:
		drag_current_pos = (event as InputEventMouseMotion).position
		lines_layer.queue_redraw()

	if is_dragging and event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if not mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			# soltó en el vacío, sin tocar un endpoint derecho -> cancelamos
			is_dragging = false
			drag_from_left = -1
			lines_layer.queue_redraw()


func draw_wires(canvas: CanvasItem) -> void:
	for left_idx in connections.keys():
		var right_idx: int = connections[left_idx]
		var color: Color = wire_colors[left_idx]
		var from: Vector2 = left_endpoints[left_idx].get_center_global() - lines_layer.global_position
		var to: Vector2 = right_endpoints[right_idx].get_center_global() - lines_layer.global_position
		canvas.draw_line(from, to, color, wire_thickness)

	if is_dragging and drag_from_left != -1:
		var color: Color = wire_colors[drag_from_left]
		var from: Vector2 = left_endpoints[drag_from_left].get_center_global() - lines_layer.global_position
		canvas.draw_line(from, drag_current_pos, color, wire_thickness)


func _check_completion() -> void:
	if connections.size() < correct_pairs.size():
		return

	for left_idx in correct_pairs.keys():
		if connections.get(left_idx, -1) != correct_pairs[left_idx]:
			return

	if feedback_label:
		feedback_label.text = "¡Completado!"
	complete()
