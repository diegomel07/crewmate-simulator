# res://scenes/minigames/clear_asteroids/Asteroid.gd
class_name Asteroid
extends Control

signal destroyed(asteroid: Asteroid, points: int)
signal reached_target(asteroid: Asteroid)

@export var rotation_speed_range: Vector2 = Vector2(-3.0, 3.0)  # radianes/seg
@export var separation_radius: float = 50.0    # distancia mínima entre asteroides
@export var separation_weight: float = 0.6     # qué tanto pesa "no chocar" vs ir al centro
@export var off_screen_margin: float = 60.0    # margen extra antes de limpiar el asteroide

var target_pos: Vector2
var speed: float = 80.0
var points: int = 10
var rotation_speed: float = 0.0

var _has_reached_target: bool = false
var _travel_dir: Vector2 = Vector2.ZERO   # dirección congelada una vez que pasó el target

@onready var art: Node = $AsteroidArt   # TODO: tu arte acá (Sprite2D / TextureRect)


func setup(p_size: float, p_speed: float, p_points: int) -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	size = Vector2(p_size, p_size)
	speed = p_speed
	points = p_points
	rotation_speed = randf_range(rotation_speed_range.x, rotation_speed_range.y)

	if art is Node2D:
		art.position = size / 2.0
	pivot_offset = size / 2.0   # para que rote sobre su propio centro, no la esquina


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	if art:
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE   # placeholder no debe tapar el click


func _process(delta: float) -> void:
	rotation += rotation_speed * delta

	if not _has_reached_target:
		var dir_to_target: Vector2 = (target_pos - position).normalized()
		var separation: Vector2 = _compute_separation()

		var final_dir: Vector2 = (dir_to_target + separation * separation_weight).normalized()
		position += final_dir * speed * delta

		if position.distance_to(target_pos) < 20.0:
			_has_reached_target = true
			_travel_dir = final_dir   # se congela la dirección: sigue de largo en línea recta
			reached_target.emit(self)
	else:
		# Ya pasó el target: no se destruye, sigue su camino hasta salir de pantalla.
		position += _travel_dir * speed * delta
		if _is_off_screen():
			queue_free()


func _is_off_screen() -> bool:
	var bounds: Vector2 = _get_bounds()
	var m := off_screen_margin
	return position.x < -m or position.y < -m or position.x > bounds.x + m or position.y > bounds.y + m


func _get_bounds() -> Vector2:
	var parent := get_parent()
	if parent is Control:
		return (parent as Control).size
	return get_viewport_rect().size


func _compute_separation() -> Vector2:
	var push := Vector2.ZERO
	var parent := get_parent()
	if parent == null:
		return push

	for sibling in parent.get_children():
		if sibling == self or not (sibling is Asteroid):
			continue
		var to_self: Vector2 = position - sibling.position
		var dist: float = to_self.length()
		if dist < separation_radius and dist > 0.001:
			# cuanto más cerca, más fuerte empuja (inversamente proporcional a la distancia)
			push += to_self.normalized() * (separation_radius - dist) / separation_radius

	return push


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			destroyed.emit(self, points)
			queue_free()
