# res://scenes/minigames/wires/LinesLayer.gd
class_name WiresLinesLayer
extends Control

var wires_minigame: WiresMinigame  # referencia al padre, se setea desde afuera


func _draw() -> void:
	if wires_minigame:
		wires_minigame.draw_wires(self)
