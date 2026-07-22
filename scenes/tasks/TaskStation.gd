# res://scenes/tasks/TaskStation.gd
extends Area3D

@export var task_id: String = "wires"   # debe coincidir con minigame_registry
@export var interact_action: String = "interact"  # nombre de la acción en Input Map

@onready var prompt_label: Label3D = $PromptLabel3D
@onready var minimap_icon: Node3D = $MiniMapIcon

var player_in_range: bool = false
var is_completed: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	MinigameManager.minigame_finished.connect(_on_minigame_finished)
	prompt_label.visible = false


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not is_completed:
		player_in_range = true
		prompt_label.visible = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		prompt_label.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and not is_completed and event.is_action_pressed(interact_action):
		prompt_label.visible = false
		MinigameManager.open_minigame(task_id)


func _on_minigame_finished(finished_task_id: String, success: bool) -> void:
	# Si la tarea terminada no es esta estación, ignoramos la señal
	if finished_task_id != task_id:
		return

	if success:
		# El jugador completó el minijuego
		is_completed = true
		prompt_label.visible = false
		
		# Apagamos la X roja del minimapa
		if minimap_icon:
			minimap_icon.hide()
			
	else:
		# El jugador falló o canceló, puede reintentar si sigue en rango
		if player_in_range:
			prompt_label.visible = true
