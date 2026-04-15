extends Area2D

@export var speed: float = 140.0
@export var hp: int = 1
@export var destroy_sound: AudioStream
@export var score_value: int = 150
@export var enemy_bullet_scene: PackedScene

@onready var shoot_point = $shootpoint
@onready var shoot_timer = $shoottimer

@export var upgrade_pickup_scene: PackedScene
@export var drop_chance: float = 1
@export var possible_upgrades: Array[String] = ["spread_shot", "speed_up", "fire_rate", "shield"]


func _ready():
	add_to_group("enemies")
	#shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	var game = get_tree().current_scene
	if game != null and game.has_method("get_enemy_fire_interval_for_round"):
		shoot_timer.wait_time = game.get_enemy_fire_interval_for_round()

	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	
func _process(delta):
	global_position.y += speed * delta

	if global_position.y > get_viewport_rect().size.y + 32:
		queue_free()

func take_damage(amount: int = 1):
	hp -= amount
	if hp <= 0:
		die(true)

func die(give_score: bool = true):
	AudioManager.play_explode()

	if give_score:
		var game = get_tree().current_scene
		if game != null and game.has_method("add_score"):
			game.add_score(score_value)
		
		try_drop_upgrade()

	queue_free()

func shoot():
	if enemy_bullet_scene == null:
		return

	var game = get_tree().current_scene
	var bullet_speed = 250.0

	if game != null and game.has_method("get_enemy_bullet_speed_for_round"):
		bullet_speed = game.get_enemy_bullet_speed_for_round()

	var bullet_left = enemy_bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet_left)
	bullet_left.global_position = shoot_point.global_position
	bullet_left.direction = Vector2(-0.5, 1).normalized()
	bullet_left.speed = bullet_speed

	var bullet_right = enemy_bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet_right)
	bullet_right.global_position = shoot_point.global_position
	bullet_right.direction = Vector2(0.5, 1).normalized()
	bullet_right.speed = bullet_speed
	
func _on_shoot_timer_timeout():
	shoot()	
	
func try_drop_upgrade():
	if upgrade_pickup_scene == null:
		return

	if possible_upgrades.is_empty():
		return

	if randf() > drop_chance:
		return

	var pickup = upgrade_pickup_scene.instantiate()
	get_tree().current_scene.add_child(pickup)
	pickup.global_position = global_position

	var random_upgrade = possible_upgrades.pick_random()
	pickup.upgrade_id = random_upgrade
	
	if pickup.has_method("apply_visual"):
		pickup.apply_visual()	
