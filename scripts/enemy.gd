extends Area2D

@export var speed: float = 120.0
@export var hp: int = 1

func _process(delta):
	global_position.y += speed * delta

	if global_position.y > get_viewport_rect().size.y + 32:
		queue_free()

func take_damage(amount: int = 1):
	hp -= amount

	if hp <= 0:
		die()

func die():
	queue_free()
