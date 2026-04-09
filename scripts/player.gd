extends CharacterBody2D

@export var speed: float = 250.0

@onready var shoot_point = $shootpoint
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.2

var can_shoot := true

var screen_size: Vector2

func _ready():
	screen_size = get_viewport_rect().size

func _physics_process(delta):
	var input_vector = Vector2.ZERO

	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")

	velocity = input_vector.normalized() * speed
	move_and_slide()

	clamp_to_screen()
	
	if Input.is_action_pressed("ui_accept") and can_shoot:
		can_shoot = false
		shoot()

		var timer = get_tree().create_timer(fire_rate)
		timer.timeout.connect(reset_fire)

func clamp_to_screen():
	global_position.x = clamp(global_position.x, 0, screen_size.x)
	global_position.y = clamp(global_position.y, 0, screen_size.y)
	
func shoot():
	if bullet_scene == null:
		return

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = shoot_point.global_position

func reset_fire():
	can_shoot = true	
