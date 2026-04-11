extends Area2D

@export var speed: float = 80.0
@export var upgrade_id: String = "spread_shot"

func _process(delta):
	global_position.y += speed * delta

	if global_position.y > get_viewport_rect().size.y + 32:
		queue_free()

func _on_body_entered(body):
	if body.has_method("apply_upgrade"):
		body.apply_upgrade(upgrade_id)
		queue_free()
