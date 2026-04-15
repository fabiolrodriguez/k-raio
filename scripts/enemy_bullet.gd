extends Area2D

@export var speed: float = 250.0
var direction: Vector2 = Vector2.DOWN

func _process(delta):
	#global_position.y += speed * delta
	global_position += direction * speed * delta
	
	#if global_position.y > get_viewport_rect().size.y + 32:
		#queue_free()
	var screen_size = get_viewport_rect().size
	if global_position.y > screen_size.y + 32 or global_position.x < -32 or global_position.x > screen_size.x + 32:
		queue_free()		

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()
		queue_free()

func _ready():
	add_to_group("enemy_bullets")
