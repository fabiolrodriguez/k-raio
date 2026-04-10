extends Node

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 1.5
@export var spawn_margin: int = 24

@onready var spawn_timer = $spawntimer

var screen_size: Vector2

func _ready():
	screen_size = get_viewport().get_visible_rect().size
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func spawn_enemy():
	if enemy_scene == null:
		return

	var enemy = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)

	var random_x = randf_range(spawn_margin, screen_size.x - spawn_margin)
	enemy.global_position = Vector2(random_x, -32)

func _on_spawn_timer_timeout():
	spawn_enemy()
