extends Area2D

@export var speed: float = 80.0
@export var upgrade_id: String = "spread_shot"
@onready var texture = $upgrade

var upgrade_colors = {
	"spread_shot": Color(1.0, 0.3, 0.3),   # vermelho
	"speed_up": Color(0.3, 0.8, 1.0),      # azul claro
	"fire_rate": Color(1.0, 0.9, 0.3),     # amarelo
	"shield": Color(0.4, 1.0, 0.5)         # verde
}

func _process(delta):
	global_position.y += speed * delta

	if global_position.y > get_viewport_rect().size.y + 32:
		queue_free()
		
func _ready():
	apply_visual()		

func _on_body_entered(body):
	if body.has_method("apply_upgrade"):
		body.apply_upgrade(upgrade_id)
		queue_free()

func apply_visual():
	if texture == null:
		return

	if upgrade_colors.has(upgrade_id):
		texture.modulate = upgrade_colors[upgrade_id]
	else:
		texture.modulate = Color.WHITE
