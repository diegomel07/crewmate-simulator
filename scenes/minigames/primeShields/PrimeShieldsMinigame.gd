# res://scenes/minigames/prime_shields/PrimeShieldsMinigame.gd
class_name PrimeShieldsMinigame
extends MinigameBase

@export var hex_tile_scene: PackedScene = preload("res://scenes/minigames/primeShields/HexTile.tscn")
@export var hex_grid_radius: int = 2          # 2 = 19 hexágonos (igual que en la imagen de referencia)
@export var hex_size: float = 42.0            # tamaño de cada hexágono
@export var red_count_range: Vector2i = Vector2i(5, 8)   # cuántos arrancan rojos

@onready var hex_grid: Control = $HexGrid
@onready var feedback_label: Label = $FeedbackLabel

var tiles: Array[HexTile] = []
var red_remaining: int = 0


func _on_minigame_ready() -> void:
	call_deferred("_spawn_hex_grid")


func _spawn_hex_grid() -> void:
	var coords: Array[Vector2i] = _generate_axial_coords(hex_grid_radius)
	var center: Vector2 = hex_grid.size / 2.0

	for coord in coords:
		var tile: HexTile = hex_tile_scene.instantiate()
		tile.hex_radius = hex_size
		tile.is_red = false
		hex_grid.add_child(tile)

		var pixel_pos: Vector2 = _axial_to_pixel(coord.x, coord.y, hex_size)
		tile.position = center + pixel_pos - tile.size / 2.0

		tile.hex_clicked.connect(_on_hex_clicked)
		tiles.append(tile)

	_assign_red_hexagons()


func _generate_axial_coords(radius: int) -> Array[Vector2i]:
	# genera coordenadas axiales (q, r) para un hexágono "grande"
	# formado por hexágonos chicos, de radio N (radius=2 -> 19 celdas)
	var result: Array[Vector2i] = []
	for q in range(-radius, radius + 1):
		for r in range(-radius, radius + 1):
			if abs(q + r) <= radius:
				result.append(Vector2i(q, r))
	return result


func _axial_to_pixel(q: int, r: int, size: float) -> Vector2:
	# conversión estándar de coordenadas axiales a píxeles, orientación pointy-top
	var x: float = size * sqrt(3.0) * (q + r / 2.0)
	var y: float = size * 1.5 * r
	return Vector2(x, y)


func _assign_red_hexagons() -> void:
	var count: int = randi_range(red_count_range.x, red_count_range.y)
	count = min(count, tiles.size())

	var shuffled: Array[HexTile] = tiles.duplicate()
	shuffled.shuffle()

	for i in count:
		shuffled[i].set_red(true)

	red_remaining = count
	_update_feedback()


func _on_hex_clicked(tile: HexTile) -> void:
	tile.set_red(false)
	red_remaining -= 1
	_update_feedback()

	if red_remaining <= 0:
		complete()


func _update_feedback() -> void:
	feedback_label.text = "Hexágonos rojos restantes: %d" % red_remaining
