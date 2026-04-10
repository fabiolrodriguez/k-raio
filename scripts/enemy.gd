extends Area2D

@export var speed: float = 120.0
@export var hp: int = 1
@export var score_value: int = 100

@export var enemy_bullet_scene: PackedScene
@export var can_shoot: bool = true

@onready var shoot_point = $shootpoint
@onready var shoot_timer = $shoottimer

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

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()
		die(false)

func _ready():
	if can_shoot:
		shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	else:
		shoot_timer.stop()
		
func shoot():
	if enemy_bullet_scene == null:
		return

	var bullet = enemy_bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = shoot_point.global_position

func _on_shoot_timer_timeout():
	shoot()
		
