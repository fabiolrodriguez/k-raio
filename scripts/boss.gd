extends Area2D

signal boss_defeated
signal boss_health_changed(current_hp, max_hp)

@export var hp: int = 150
@export var speed: float = 80.0
@export var stop_y: float = 100.0
@export var horizontal_speed: float = 80.0
@export var move_range: float = 400.0
@export var score_value: int = 3000
@export var destroy_sound: AudioStream
@export var enemy_bullet_scene: PackedScene

@onready var shoot_point_left = $shootpointleft
@onready var shoot_point_center = $shootpoint
@onready var shoot_point_right = $shootpointright
@onready var shoot_timer = $shoottimer

var entered_position := false
var moving_right := true
var start_x := 0.0
var max_hp: int

func _ready():
	#start_x = global_position.x
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	max_hp = hp

func _process(delta):
	if not entered_position:
		global_position.y += speed * delta

		if global_position.y >= stop_y:
			global_position.y = stop_y
			entered_position = true
	else:
		if moving_right:
			global_position.x += horizontal_speed * delta
			if global_position.x >= start_x + move_range:
				moving_right = false
		else:
			global_position.x -= horizontal_speed * delta
			if global_position.x <= start_x - move_range:
				moving_right = true
				
func take_damage(amount: int = 1):
	hp -= amount
	emit_signal("boss_health_changed", hp, max_hp)
	
	if hp <= 0:
		die()

func die():
	AudioManager.play_explode()

	var game = get_tree().current_scene
	if game != null and game.has_method("add_score"):
		game.add_score(score_value)

	emit_signal("boss_defeated")
	queue_free()
	
func shoot():
	if enemy_bullet_scene == null:
		return

	var shoot_points = [
		shoot_point_left,
		shoot_point_center,
		shoot_point_right
	]

	var chosen_point = shoot_points.pick_random()

	var bullet = enemy_bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = chosen_point.global_position
	bullet.direction = Vector2.DOWN			


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()
		
func _on_shoot_timer_timeout():
	if entered_position:
		shoot()		

func set_movement_origin():
	start_x = global_position.x
