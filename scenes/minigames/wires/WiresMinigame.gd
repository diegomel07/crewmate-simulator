# res://scenes/minigames/wires/WiresMinigame.gd
class_name WiresMinigame
extends MinigameBase

@export var endpoint_scene: PackedScene = preload("res://scenes/minigames/wires/WireEndpoint.tscn")

# Colores en el mismo orden que tus cables (rojo, negro, azul, amarillo)
@export var wire_colors: Array[Color] = [
	Color(0.85, 0.15, 0.15),   # rojo
	Color("fe01ff"),   # negro
	Color(0.15, 0.35, 0.85),   # azul
	Color(0.9, 0.75, 0.1),     # amarillo
]

@export var wire_thickness: float = 9.0

# Posiciones EXACTAS en píxeles, medidas sobre tu imagen de 504x504.
# Ajustá estos valores si no calzan pixel-perfect con tus conectores blancos.
@export var left_positions: Array[Vector2] = [
	Vector2(29, 95),
	Vector2(29, 200),
	Vector2(29, 302),
	Vector2(29, 405),
]

@export var right_positions: Array[Vector2] = [
	Vector2(476, 95),
	Vector2(476, 200),
	Vector2(476, 302),
	Vector2(476, 405),
]

@onready var lines_layer: WiresLinesLayer = $LinesLayer
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
	custom_minimum_size = Vector2(504, 504)
	size = Vector2(504, 504)
	call_deferred("_setup_wires")


func _setup_wires() -> void:
	lines_layer.wires_minigame = self

	var count: int = wire_colors.size()

	# Mezclamos a qué posición derecha corresponde cada color de la izquierda
	var order := range(count)
	order.shuffle()

	for i in count:
		var left_ep: WireEndpoint = endpoint_scene.instantiate()
		left_container.add_child(left_ep)
		left_ep.position = left_positions[i] - left_ep.size / 2.0
		left_ep.color = wire_colors[i]
		left_ep.endpoint_clicked.connect(_on_left_endpoint_clicked.bind(i))
		left_endpoints.append(left_ep)

		var right_ep: WireEndpoint = endpoint_scene.instantiate()
		right_ep.get_children()[0].flip_h = true
		right_container.add_child(right_ep)
		right_ep.position = right_positions[i] - right_ep.size / 2.0
		right_endpoints.append(right_ep)

		correct_pairs[i] = order[i]

	# Asignamos el color REAL a cada endpoint derecho según el mapeo generado
	for left_idx in correct_pairs.keys():
		var right_idx: int = correct_pairs[left_idx]
		right_endpoints[right_idx].color = wire_colors[left_idx]
		right_endpoints[right_idx].endpoint_clicked.connect(_on_right_endpoint_clicked.bind(right_idx))

	lines_layer.queue_redraw()


func _on_left_endpoint_clicked(_ednpoint: WireEndpoint, left_idx: int) -> void:
	connections.erase(left_idx)
	is_dragging = true
	drag_from_left = left_idx
	drag_current_pos = left_endpoints[left_idx].get_center_global() - lines_layer.global_position
	lines_layer.queue_redraw()


func _on_right_endpoint_clicked(_ednpoint: WireEndpoint, right_idx: int) -> void:
	if is_dragging and drag_from_left != -1:
		if not connections.values().has(right_idx):
			connections[drag_from_left] = right_idx
		is_dragging = false
		drag_from_left = -1
		lines_layer.queue_redraw()
		_check_completion()
		return

	for left_idx in connections.keys():
		if connections[left_idx] == right_idx:
			connections.erase(left_idx)
			lines_layer.queue_redraw()
			break


func _gui_input(event: InputEvent) -> void:
	if is_dragging and event is InputEventMouseMotion:
		drag_current_pos = (event as InputEventMouseMotion).position - lines_layer.position
		lines_layer.queue_redraw()

	if is_dragging and event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if not mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = false
			drag_from_left = -1
			lines_layer.queue_redraw()


func _check_completion() -> void:
	if connections.size() < correct_pairs.size():
		return

	for left_idx in correct_pairs.keys():
		if connections.get(left_idx, -1) != correct_pairs[left_idx]:
			return

	if feedback_label:
		feedback_label.text = "¡Completado!"
	complete()
