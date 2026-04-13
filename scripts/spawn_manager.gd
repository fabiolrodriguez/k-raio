extends Node

@export var enemy_scene: PackedScene
@export var enemy_diag: PackedScene
@export var enemy_suicide_scene: PackedScene
@export var spawn_interval: float = 1.5
@export var spawn_margin: int = 24

@onready var spawn_timer = $spawntimer
@onready var difficulty_timer = $difficultytimer
var diagonal_unlocked := false
var suicide_unlocked := false

var screen_size: Vector2

func _ready():
	screen_size = get_viewport().get_visible_rect().size
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	difficulty_timer.wait_time = spawn_interval
	difficulty_timer.timeout.connect(_on_difficulty_timer_timeout)

func spawn_enemy():
	var scene_to_spawn = get_enemy_scene_for_spawn()

	if scene_to_spawn == null:
		return

	var enemy = scene_to_spawn.instantiate()

	if enemy_suicide_scene != null and scene_to_spawn == enemy_suicide_scene:
		setup_suicide_enemy(enemy)
	else:
		enemy.global_position = get_random_spawn_position()

	get_tree().current_scene.add_child(enemy)

func get_enemy_scene_for_spawn() -> PackedScene:
	var roll = randf()

	if suicide_unlocked and enemy_suicide_scene != null:
		if roll < 0.25:
			return enemy_suicide_scene

	if diagonal_unlocked and enemy_diag != null:
		if roll < 0.45:
			return enemy_diag

	return enemy_scene

func setup_suicide_enemy(enemy):
	var from_left = randf() < 0.5
	var y_pos = randf_range(10, 180)

	if from_left:
		enemy.global_position = Vector2(-32, y_pos)

		if enemy.has_method("set_direction"):
			enemy.set_direction(Vector2(0.8, 1))
	else:
		enemy.global_position = Vector2(screen_size.x + 32, y_pos)

		if enemy.has_method("set_direction"):
			enemy.set_direction(Vector2(-0.8, 1))			

func spawn_suicide_enemy(enemy):
	var from_left = randf() < 0.5
	var y_pos = randf_range(40, 180)

	print("Spawning suicide enemy. from_left:", from_left, " y:", y_pos)

	if from_left:
		enemy.global_position = Vector2(-32, y_pos)
		print("Position set to:", enemy.global_position)

		if enemy.has_method("set_direction"):
			enemy.set_direction(Vector2(0.8, 1))
		else:
			print("EnemySuicide does NOT have set_direction")
	else:
		enemy.global_position = Vector2(screen_size.x + 32, y_pos)
		print("Position set to:", enemy.global_position)

		if enemy.has_method("set_direction"):
			enemy.set_direction(Vector2(-0.8, 1))
		else:
			print("EnemySuicide does NOT have set_direction")

func _on_spawn_timer_timeout():
	spawn_enemy()

var difficulty_stage := 0

func _on_difficulty_timer_timeout():
	difficulty_stage += 1

	if difficulty_stage == 1:
		diagonal_unlocked = true
		spawn_timer.wait_time = 1.0

		difficulty_timer.wait_time = 1.0
		difficulty_timer.start()

	elif difficulty_stage == 2:
		suicide_unlocked = true
		spawn_timer.wait_time = 0.85
		
func get_random_spawn_position() -> Vector2:
	var random_x = randf_range(spawn_margin, screen_size.x - spawn_margin)
	return Vector2(random_x, -32)		
		
