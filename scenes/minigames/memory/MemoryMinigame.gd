# res://scenes/minigames/memory/MemoryMinigame.gd
class_name MemoryMinigame
extends MinigameBase

@export var grid_button_scene: PackedScene = preload("res://scenes/minigames/memory/GridButton.tscn")
@export var light_scene: PackedScene = preload("res://scenes/minigames/memory/LightIndicator.tscn")

@export var grid_columns: int = 3
@export var grid_rows: int = 3
@export var total_rounds: int = 3          # cuántos pasos tendrá la secuencia final
@export var flash_duration: float = 0.5
@export var pause_between_flashes: float = 0.25
@export var reset_round_on_fail: bool = true   # false = fail() directo del minijuego entero

@onready var progress_lights_container: HBoxContainer = $LeftPanel/ProgressLights
@onready var display_grid: GridContainer = $LeftPanel/DisplayScreen/DisplayGrid
@onready var button_grid: GridContainer = $RightPanel/ButtonGrid
@onready var feedback_label: Label = $FeedbackLabel

var display_cells: Array[GridButton] = []   # solo visuales, en la pantalla negra
var buttons: Array[GridButton] = []          # los reales, clickeables, a la derecha
var lights: Array[LightIndicator] = []

var sequence: Array[int] = []
var current_round: int = 1          # ronda actual (empieza en 1)
var player_progress: int = 0        # cuántos pasos de la secuencia actual ya acertó
var is_showing_sequence: bool = false


func _on_minigame_ready() -> void:
	display_grid.columns = grid_columns
	button_grid.columns = grid_columns

	_spawn_display_cells()
	_spawn_buttons()
	_spawn_lights()
	_generate_full_sequence()
	call_deferred("_play_current_round")


func _spawn_display_cells() -> void:
	var total: int = grid_columns * grid_rows
	for i in total:
		var cell: GridButton = grid_button_scene.instantiate()
		display_grid.add_child(cell)
		cell.index = i
		cell.interactive = false   # solo se ve, nunca recibe clicks
		display_cells.append(cell)


func _spawn_buttons() -> void:
	var total: int = grid_columns * grid_rows
	for i in total:
		var btn: GridButton = grid_button_scene.instantiate()
		button_grid.add_child(btn)
		btn.index = i
		btn.interactive = true
		btn.button_pressed.connect(_on_button_pressed)
		buttons.append(btn)


func _spawn_lights() -> void:
	for i in total_rounds:
		var light: LightIndicator = light_scene.instantiate()
		progress_lights_container.add_child(light)
		lights.append(light)


func _generate_full_sequence() -> void:
	sequence.clear()
	var total: int = grid_columns * grid_rows
	for i in total_rounds:
		sequence.append(randi() % total)


func _play_current_round() -> void:
	is_showing_sequence = true
	player_progress = 0
	_set_buttons_locked(true)
	feedback_label.text = "Mirá con atención..."

	for step in current_round:
		await get_tree().create_timer(pause_between_flashes, true).timeout
		var cell_index: int = sequence[step]
		await display_cells[cell_index].flash(flash_duration)   # <- ahora flashea en la IZQUIERDA

	is_showing_sequence = false
	_set_buttons_locked(false)
	feedback_label.text = "Ahora repetí la secuencia"


func _set_buttons_locked(locked: bool) -> void:
	for btn in buttons:
		btn.is_locked = locked


func _on_button_pressed(index: int) -> void:
	if is_showing_sequence:
		return

	buttons[index].flash(0.2)   # feedback visual rápido del click, no bloqueante

	var expected_index: int = sequence[player_progress]

	if index != expected_index:
		_on_wrong_input()
		return

	player_progress += 1

	if player_progress >= current_round:
		_on_round_completed()


func _on_wrong_input() -> void:
	feedback_label.text = "¡Fallaste!"

	if reset_round_on_fail:
		await get_tree().create_timer(0.8, true).timeout
		_play_current_round()   # repite la misma ronda desde el principio
	else:
		fail()


func _on_round_completed() -> void:
	lights[current_round - 1].set_on(true)
	feedback_label.text = "¡Correcto!"

	if current_round >= total_rounds:
		await get_tree().create_timer(0.5, true).timeout
		complete()
		return

	current_round += 1
	await get_tree().create_timer(0.8, true).timeout
	_play_current_round()
