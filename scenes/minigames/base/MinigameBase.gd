# res://scenes/minigames/base/MinigameBase.gd
class_name MinigameBase
extends Control

signal minigame_completed
signal minigame_failed

# Tiempo límite opcional (0 = sin límite)
@export var time_limit: float = 0.0

var _time_elapsed: float = 0.0
var _is_finished: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_on_minigame_ready()


func _process(delta: float) -> void:
	if time_limit > 0.0 and not _is_finished:
		_time_elapsed += delta
		if _time_elapsed >= time_limit:
			fail()


# --- Métodos que cada minijuego hijo puede sobreescribir ---
func _on_minigame_ready() -> void:
	pass


# --- Métodos que cada minijuego hijo debe LLAMAR cuando corresponda ---
func complete() -> void:
	if _is_finished:
		return
	_is_finished = true
	minigame_completed.emit()


func fail() -> void:
	if _is_finished:
		return
	_is_finished = true
	minigame_failed.emit()
