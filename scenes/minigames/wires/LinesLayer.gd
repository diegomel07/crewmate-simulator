# res://scenes/minigames/wires/LinesLayer.gd
class_name WiresLinesLayer
extends Control

var wires_minigame: WiresMinigame


func _draw() -> void:
	if not wires_minigame:
		return

	for left_idx in wires_minigame.connections.keys():
		var right_idx: int = wires_minigame.connections[left_idx]
		var color: Color = wires_minigame.wire_colors[left_idx]
		var from: Vector2 = wires_minigame.left_endpoints[left_idx].get_center_global() - global_position
		var to: Vector2 = wires_minigame.right_endpoints[right_idx].get_center_global() - global_position
		draw_line(from, to, color, wires_minigame.wire_thickness)

	if wires_minigame.is_dragging and wires_minigame.drag_from_left != -1:
		var color: Color = wires_minigame.wire_colors[wires_minigame.drag_from_left]
		var from: Vector2 = wires_minigame.left_endpoints[wires_minigame.drag_from_left].get_center_global() - global_position
		draw_line(from, wires_minigame.drag_current_pos, color, wires_minigame.wire_thickness)
