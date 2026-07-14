# res://autoload/MinigameManager.gd
extends Node

signal minigame_finished(task_id: String, success: bool)
signal minigame_opened(task_id: String)

var current_minigame: Node = null
var current_task_id: String = ""

# Mapea cada task_id a su escena. Agregar acá cualquier minijuego nuevo.
var minigame_registry: Dictionary = {
	"wires":           preload("res://scenes/minigames/wires/WiresMinigame.tscn"),
	"swipe_card":      preload("res://scenes/minigames/swipeCard/SwipeCardMinigame.tscn"),
	"clear_asteroids": preload("res://scenes/minigames/clearAsteroid/ClearAsteroidsMinigame.tscn"),
	"align_engine":    preload("res://scenes/minigames/alignLine/AlignLineMinigame.tscn"),
}

var canvas_layer: CanvasLayer


func _ready() -> void:
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # por encima de todo lo demás
	canvas_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(canvas_layer)


func open_minigame(task_id: String) -> void:
	if current_minigame != null:
		push_warning("Ya hay un minijuego abierto, se ignora la nueva apertura de: " + task_id)
		return

	if not minigame_registry.has(task_id):
		push_error("No existe minijuego registrado para: " + task_id)
		return

	current_task_id = task_id

	var scene: PackedScene = minigame_registry[task_id]
	current_minigame = scene.instantiate()
	current_minigame.process_mode = Node.PROCESS_MODE_ALWAYS
	canvas_layer.add_child(current_minigame)

	current_minigame.minigame_completed.connect(_on_minigame_completed)
	current_minigame.minigame_failed.connect(_on_minigame_failed)

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)   # <- agregar esto
	get_tree().paused = true
	minigame_opened.emit(task_id)


func _close_minigame(success: bool) -> void:
	var finished_task_id := current_task_id

	if current_minigame != null:
		current_minigame.queue_free()
		current_minigame = null

	current_task_id = ""
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)   # <- agregar esto

	minigame_finished.emit(finished_task_id, success)


func _on_minigame_completed() -> void:
	_close_minigame(true)


func _on_minigame_failed() -> void:
	_close_minigame(false)
