extends Area2D

@export var speed: float = 250.0

func _process(delta):
	global_position.y += speed * delta

	if global_position.y > get_viewport_rect().size.y + 32:
		queue_free()



func _on_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()
		queue_free()
