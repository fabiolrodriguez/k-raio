extends Area2D

@export var speed: float = 500.0

var direction: Vector2 = Vector2.UP

func _process(delta):
	global_position += direction * speed * delta

	if global_position.y < -20:
		queue_free()

func _on_area_entered(area):
	if area.has_method("take_damage"):
		area.take_damage(1)
		queue_free()
