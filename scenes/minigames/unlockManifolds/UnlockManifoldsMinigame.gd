# res://scenes/minigames/unlock_manifolds/UnlockManifoldsMinigame.gd
class_name UnlockManifoldsMinigame
extends MinigameBase

@export var tile_scene: PackedScene = preload("res://scenes/minigames/unlockManifolds/NumberTile.tscn")
@export var total_numbers: int = 10
@export var flash_duration: float = 0.3
@export var flash_color: Color = Color(0.8, 0.15, 0.15)

@onready var number_grid: GridContainer = $NumberGrid
@onready var feedback_label: Label = $FeedbackLabel
@onready var background: ColorRect = $Background

var tiles: Array[NumberTile] = []
var next_expected: int = 1
var original_background_color: Color
var is_flashing: bool = false


func _on_minigame_ready() -> void:
	original_background_color = background.color
	number_grid.columns = 5
	_spawn_tiles()


func _spawn_tiles() -> void:
	var numbers: Array = range(1, total_numbers + 1)
	numbers.shuffle()

	for n in numbers:
		var tile: NumberTile = tile_scene.instantiate()
		tile.value = n                          # <- asignar ANTES de add_child
		number_grid.add_child(tile)              # <- ahora _ready() ya ve el valor correcto
		tile.tile_pressed.connect(_on_tile_pressed)
		tiles.append(tile)


func _on_tile_pressed(value: int) -> void:
	if is_flashing:
		return   # el teclado está "congelado" durante el flash rojo, ignoramos clicks

	if value == next_expected:
		_mark_tile_correct(value)
		next_expected += 1
		feedback_label.text = ""

		if next_expected > total_numbers:
			complete()
	else:
		_on_wrong_tile()


func _mark_tile_correct(value: int) -> void:
	for tile in tiles:
		if tile.value == value:
			tile.set_correct(true)
			break


func _on_wrong_tile() -> void:
	feedback_label.text = "¡Incorrecto! Reiniciando secuencia..."
	_reset_progress()
	_flash_keypad_red()


func _reset_progress() -> void:
	# El progreso se reinicia, PERO los números NO se reordenan
	# (eso solo pasa si se abandona la tarea del todo, ver nota arriba)
	next_expected = 1
	for tile in tiles:
		tile.reset()


func _flash_keypad_red() -> void:
	is_flashing = true
	for tile in tiles:
		tile.is_locked = true

	background.color = flash_color

	await get_tree().create_timer(flash_duration, true).timeout

	background.color = original_background_color
	for tile in tiles:
		tile.is_locked = false
	is_flashing = false
