extends CanvasLayer

@onready var task_label: Label = $TaskLabel
@onready var final_warning: Label = $FinalWarning
func _ready() -> void:
	_update_label()
	MinigameManager.minigame_finished.connect(_on_minigame_finished)

func _on_minigame_finished(_task_id: String, success: bool) -> void:
	if success:
		_update_label()
		if MinigameManager.cant_minigames_completed == 1	:
			final_warning.visible = true
			

func _update_label() -> void:
	task_label.text = "Tareas completadas: %d" % MinigameManager.cant_minigames_completed
