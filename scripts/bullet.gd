extends Area2D

@export var speed: float = 500.0

func _process(delta):
	global_position.y -= speed * delta

	if global_position.y < -20:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(1)
		queue_free()
