extends Node

@export var enemy_scene: PackedScene
@export var enemy_diag: PackedScene
@export var spawn_interval: float = 1.5
@export var spawn_margin: int = 24

@onready var spawn_timer = $spawntimer
@onready var difficulty_timer = $difficultytimer
var diagonal_unlocked := false

var screen_size: Vector2

func _ready():
	screen_size = get_viewport().get_visible_rect().size
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	difficulty_timer.wait_time = spawn_interval
	difficulty_timer.timeout.connect(_on_difficulty_timer_timeout)

func spawn_enemy():
	if enemy_scene == null:
		return

	var enemy = get_enemy_scene_for_spawn().instantiate()
	get_tree().current_scene.add_child(enemy)

	var random_x = randf_range(spawn_margin, screen_size.x - spawn_margin)
	enemy.global_position = Vector2(random_x, -32)
	
func get_enemy_scene_for_spawn() -> PackedScene:
	if diagonal_unlocked and enemy_diag != null:
		if randf() < 0.35:
			return enemy_diag

	return enemy_scene

func _on_spawn_timer_timeout():
	spawn_enemy()

func _on_difficulty_timer_timeout():
	diagonal_unlocked = true
	spawn_timer.wait_time = 1.0
