extends Area2D

@export var speed: float = 120.0
@export var hp: int = 1
var score = 0

func _process(delta):
	global_position.y += speed * delta

	if global_position.y > get_viewport_rect().size.y + 32:
		queue_free()

func take_damage(amount: int = 1):
	hp -= amount

	if hp <= 0:
		die()

func die():
	AudioManager.play_explode()
	queue_free()
	score += 1


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()
		die()	
