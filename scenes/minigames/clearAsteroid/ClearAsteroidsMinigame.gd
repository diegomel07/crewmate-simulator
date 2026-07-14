# res://scenes/minigames/clear_asteroids/ClearAsteroidsMinigame.gd
class_name ClearAsteroidsMinigame
extends MinigameBase

@export var asteroid_scene: PackedScene = preload("res://scenes/minigames/clearAsteroid/Asteroid.tscn")
@export var total_asteroids: int = 10
@export var max_reach_target: int = 3

# Rango de tamaño: los chicos son más rápidos y valen más puntos
@export var size_range: Vector2 = Vector2(28.0, 60.0)
@export var base_speed_range: Vector2 = Vector2(60.0, 120.0)

# Dificultad creciente: cada cuántos segundos aumenta la velocidad de spawn
@export var difficulty_ramp_interval: float = 5.0
@export var difficulty_speed_bonus: float = 25.0   # cuánto se suma al rango de velocidad por "nivel"

@export var required_points: int = 80   # puntos necesarios para completar la tarea
@export var spawn_interval_range: Vector2 = Vector2(0.5, 1.2)

@onready var asteroids_layer: Control = $AsteroidsLayer
@onready var target_area: Control = $TargetArea
@onready var info_label: Label = $InfoLabel

var spawned_count: int = 0
var reached_count: int = 0
var total_points: int = 0

var spawn_timer: float = 0.0
var next_spawn_time: float = 0.0

var elapsed_time: float = 0.0
var difficulty_level: int = 0


func _on_minigame_ready() -> void:
	_schedule_next_spawn()
	_update_label()


func _process(delta: float) -> void:
	elapsed_time += delta
	_update_difficulty()

	if spawned_count < total_asteroids:
		spawn_timer += delta
		if spawn_timer >= next_spawn_time:
			_spawn_asteroid()
			spawn_timer = 0.0
			_schedule_next_spawn()

	super._process(delta)


func _update_difficulty() -> void:
	var expected_level: int = int(elapsed_time / difficulty_ramp_interval)
	if expected_level > difficulty_level:
		difficulty_level = expected_level


func _current_speed_range() -> Vector2:
	var bonus: float = difficulty_level * difficulty_speed_bonus
	return Vector2(base_speed_range.x + bonus, base_speed_range.y + bonus)


func _schedule_next_spawn() -> void:
	next_spawn_time = randf_range(spawn_interval_range.x, spawn_interval_range.y)


func _spawn_asteroid() -> void:
	spawned_count += 1

	var asteroid: Asteroid = asteroid_scene.instantiate()
	asteroids_layer.add_child(asteroid)

	var rect := get_rect()
	var edge := randi() % 4
	var spawn_pos: Vector2
	match edge:
		0: spawn_pos = Vector2(randf_range(0, rect.size.x), -40)
		1: spawn_pos = Vector2(randf_range(0, rect.size.x), rect.size.y + 40)
		2: spawn_pos = Vector2(-40, randf_range(0, rect.size.y))
		_: spawn_pos = Vector2(rect.size.x + 40, randf_range(0, rect.size.y))

	# Tamaño random: determina velocidad y puntos (chico = rápido y valioso)
	var asteroid_size: float = randf_range(size_range.x, size_range.y)
	var size_ratio: float = (asteroid_size - size_range.x) / (size_range.y - size_range.x)  # 0 = chico, 1 = grande

	var speed_range: Vector2 = _current_speed_range()
	var asteroid_speed: float = lerp(speed_range.y, speed_range.x, size_ratio)  # chico -> más rápido
	var asteroid_points: int = int(lerp(20.0, 5.0, size_ratio))                 # chico -> más puntos

	asteroid.position = spawn_pos
	asteroid.target_pos = target_area.position + target_area.size / 2.0
	asteroid.setup(asteroid_size, asteroid_speed, asteroid_points)

	asteroid.destroyed.connect(_on_asteroid_destroyed)
	asteroid.reached_target.connect(_on_asteroid_reached_target)


func _on_asteroid_destroyed(_asteroid: Asteroid, points: int) -> void:
	total_points += points
	_update_label()

	if total_points >= required_points:
		complete()
		return

	_check_end_conditions()


func _on_asteroid_reached_target(_asteroid: Asteroid) -> void:
	reached_count += 1
	_update_label()

	if reached_count >= max_reach_target:
		fail()
		return

	_check_end_conditions()


func _check_end_conditions() -> void:
	# si ya se generaron todos y ninguno queda vivo, pero no se llegó al puntaje -> fallo
	var asteroids_alive := asteroids_layer.get_child_count()
	if spawned_count >= total_asteroids and asteroids_alive == 0 and total_points < required_points:
		fail()


func _update_label() -> void:
	info_label.text = "Puntos: %d / %d" % [total_points, required_points]
