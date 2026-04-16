extends CharacterBody2D

@export var speed: float = 250.0

@onready var shoot_point = $shootpoint
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.3
var is_dead := false
var can_shoot := true
var screen_size: Vector2

signal upgrades_changed

var upgrades = {
	"spread_shot": 0,
	"fire_rate": 0,
	"speed_up": 0,
	"shield": 0
}

var base_fire_rate: float = 0.2
var base_speed: float = 250.0
var shield_charges := 0
var weapon_loop_active := false
@export var shoot_sound: AudioStream
@onready var shield_sprite = $shield
var wants_to_shoot := false

func _ready():
	screen_size = get_viewport_rect().size
	shield_sprite.visible = false
func _physics_process(delta):
	if is_dead:
		return
	var input_vector = Vector2.ZERO

	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")

	velocity = input_vector.normalized() * speed
	move_and_slide()

	clamp_to_screen()
	
	if SettingsManager.auto_fire:
		wants_to_shoot = true
	else:
		wants_to_shoot = Input.is_action_pressed("ui_accept")

	if wants_to_shoot and can_shoot:
		can_shoot = false
		shoot()

		var timer = get_tree().create_timer(fire_rate)
		timer.timeout.connect(reset_fire)

	if wants_to_shoot:
		if not weapon_loop_active:
			AudioManager.start_weapon_loop(shoot_sound)
			weapon_loop_active = true
	else:
		if weapon_loop_active:
			AudioManager.stop_weapon_loop()
			weapon_loop_active = false

func clamp_to_screen():
	global_position.x = clamp(global_position.x, 0, screen_size.x)
	global_position.y = clamp(global_position.y, 0, screen_size.y)
	
func shoot():
	#AudioManager.play_shoot()

	if upgrades["spread_shot"] > 0:
		spawn_player_bullet(Vector2.UP, 0)
		spawn_player_bullet(Vector2(-0.25, -1), -8)
		spawn_player_bullet(Vector2(0.25, -1), 8)
	else:
		spawn_player_bullet(Vector2.UP, 0)

func reset_fire():
	can_shoot = true

func die():
	if is_dead:
		AudioManager.stop_weapon_loop()
		return
		
	# verifica shield antes de morrer
	if shield_charges > 0:
		shield_charges -= 1
		update_shield_visual()
		emit_signal("upgrades_changed")
		on_shield_hit()
		return

	weapon_loop_active = false

	is_dead = true

	var game = get_tree().current_scene
	if game != null and game.has_method("game_over"):
		wants_to_shoot = false
		AudioManager.stop_weapon_loop()
		game.game_over()

	queue_free()
	
func apply_upgrade(upgrade_id: String):
	if not upgrades.has(upgrade_id):
		upgrades[upgrade_id] = 0

	upgrades[upgrade_id] += 1
	
	if upgrade_id == "shield":
		shield_charges += 1
		update_shield_visual()
	
	recalculate_upgrades()
	print("Upgrade aplicado:", upgrade_id)
	print("Velocidade atual:", speed)
	
	emit_signal("upgrades_changed")
	
func recalculate_upgrades():
	fire_rate = max(0.05, base_fire_rate - (upgrades["fire_rate"] * 0.03))
	speed = base_speed + (upgrades["speed_up"] * 30.0)
	
func spawn_player_bullet(direction: Vector2, x_offset: float = 0.0):
	if bullet_scene == null:
		return

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = shoot_point.global_position + Vector2(x_offset, 0)
	bullet.direction = direction.normalized()
	
func on_shield_hit():
	print("Shield absorveu o dano!")

	if shield_sprite == null:
		return

	for i in range(3):
		shield_sprite.visible = false
		await get_tree().create_timer(0.08).timeout

		if shield_charges > 0:
			shield_sprite.visible = true
		await get_tree().create_timer(0.08).timeout

	update_shield_visual()
	
func update_shield_visual():
	if shield_sprite == null:
		return

	shield_sprite.visible = shield_charges > 0	
