extends Node3D
@onready var minimap_icon = $MinimapIcon

func _on_minigame_completed():

	if minimap_icon:
		minimap_icon.hide()
