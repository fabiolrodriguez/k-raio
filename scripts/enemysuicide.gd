extends Area2D

@export var speed: float = 260.0
@export var hp: int = 1
@export var destroy_sound: AudioStream
@export var score_value: int = 200

@export var upgrade_pickup_scene: PackedScene
@export var drop_chance: float = 0.15
@export var possible_upgrades: Array[String] = ["spread_shot", "speed_up", "fire_rate", "shield"]

var move_direction: Vector2 = Vector2.ZERO

func set_direction(direction: Vector2):
	move_direction = direction.normalized()

#func _process(delta):
	#global_position += move_direction * speed * delta
#
	#var screen_size = get_viewport_rect().size
	#if global_position.y > screen_size.y + 64 or global_position.x < -64 or global_position.x > screen_size.x + 64:
		#queue_free()
#
#func set_direction(direction: Vector2):
	#move_direction = direction.normalized()

func _process(delta):
	if move_direction == Vector2.ZERO:
		return

	global_position += move_direction * speed * delta

	var screen_size = get_viewport_rect().size
	if global_position.y > screen_size.y + 64 or global_position.x < -64 or global_position.x > screen_size.x + 64:
		queue_free()

func take_damage(amount: int = 1):
	hp -= amount

	if hp <= 0:
		die(true)

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

func die(give_score: bool = true):
	AudioManager.play_explode()

	if give_score:
		var game = get_tree().current_scene
		if game != null and game.has_method("add_score"):
			game.add_score(score_value)

		try_drop_upgrade()

	queue_free()

func _on_body_entered(body):
	if body.has_method("die"):
		body.die()
		die(false)
		
#func _ready():
	#set_direction(Vector2(0.6, 1))
