extends Area2D

@export var speed: float = 120.0
@export var hp: int = 1
@export var destroy_sound: AudioStream
@export var score_value: int = 150
@export var enemy_bullet_scene: PackedScene

@onready var shoot_point = $shootpoint
@onready var shoot_timer = $shoottimer

func _ready():
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

	queue_free()

func shoot():
	if enemy_bullet_scene == null:
		return

	# tiro esquerda
	var bullet_left = enemy_bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet_left)
	bullet_left.global_position = shoot_point.global_position
	bullet_left.direction = Vector2(-0.5, 1).normalized()

	# tiro direita
	var bullet_right = enemy_bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet_right)
	bullet_right.global_position = shoot_point.global_position
	bullet_right.direction = Vector2(0.5, 1).normalized()
	
func _on_shoot_timer_timeout():
	shoot()	
