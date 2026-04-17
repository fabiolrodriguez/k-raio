extends Node2D

@onready var pause_menu = $PauseMenu
@onready var score_label = $scorelayer/scorelabel
@onready var game_over_menu = $gameover
@onready var restart_button = $gameover/gameoverpanel/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/restart
@onready var quit_button = $gameover/gameoverpanel/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/quit

@onready var spread_label = $scorelayer/upgradehud/HBoxContainer/spreadshotbox/count
@onready var speed_label = $scorelayer/upgradehud/HBoxContainer/speedupbox/count
@onready var fire_rate_label = $scorelayer/upgradehud/HBoxContainer/fireratebox/count
@onready var shield_label = $scorelayer/upgradehud/HBoxContainer/shieldbox/count

@onready var spread_box = $scorelayer/upgradehud/HBoxContainer/spreadshotbox
@onready var speed_box = $scorelayer/upgradehud/HBoxContainer/speedupbox
@onready var fire_rate_box = $scorelayer/upgradehud/HBoxContainer/fireratebox
@onready var shield_box = $scorelayer/upgradehud/HBoxContainer/shieldbox

@onready var player = $player

@export var boss_scene: PackedScene
@onready var spawn_manager = $SpawnManager

@onready var boss_health_hud = $scorelayer/bosshud
@onready var boss_name_label = $scorelayer/bosshud/bossname
@onready var boss_health_bar = $scorelayer/bosshud/bosshealth
@onready var fade_rect = $scorelayer/blackscreen
@onready var round_label = $scorelayer/roundlabel
@onready var final_score = $gameover/gameoverpanel/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/scorelabel
@onready var final_reality = $gameover/gameoverpanel/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/reality

@export var level_bgm: AudioStream
@export var boss_bgm: AudioStream

var boss_spawned := false

var score := 0

var round := 0

var difficulty_multiplier := 1.0
var hp_multiplier := 1.0
var speed_multiplier := 1.0
var boss_spawn_in_progress := false
var boss_base_horizontal_speed := 80.0
var boss_speed_per_round := 10.0

var boss_base_stop_y := 100.0
var boss_stop_y_per_round := 20.0
var boss_max_stop_y_ratio := 0.5

var enemy_bullet_base_speed := 250.0
var enemy_bullet_speed_per_round := 12.0

var enemy_fire_interval_base := 1.5
var enemy_fire_interval_reduction_per_round := 0.06
var enemy_fire_interval_min := 0.45

var boss_fire_interval_base := 0.8
var boss_fire_interval_reduction_per_round := 0.03
var boss_fire_interval_min := 0.25


func update_texts():
	restart_button.text = LocalizationManager.tr_key("menu_restart")
	quit_button.text = LocalizationManager.tr_key("menu_quit")
	# adicione outros botões aqui

func _ready() -> void:
	update_score_ui()
	game_over_menu.visible=false
	if player != null:
		player.upgrades_changed.connect(update_upgrade_hud)
		
	update_upgrade_hud()
	update_texts()

	if not LocalizationManager.language_changed.is_connected(update_texts):
		LocalizationManager.language_changed.connect(update_texts)
		
	#await get_tree().create_timer(60.0).timeout
	#spawn_boss()
	schedule_boss_spawn(60.0)
	AudioManager.switch_to_bgm(level_bgm)
	AudioManager.set_bgm_volume(-5.0)
	AudioManager.set_boss_bgm_volume(-4.0)
	AudioManager.set_weapon_volume(-3.0)

			
func _process(delta: float) -> void:
	pass

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
	
func toggle_pause():
	if get_tree().paused:
		pause_menu.resume()
	else:
		pause_menu.pause()

func add_score(amount: int):
	score += amount
	update_score_ui()

func update_score_ui():
	score_label.text = "SCORE %d" % score

func game_over():
	#get_tree().paused
	get_tree().paused = true
	AudioManager.stop_weapon_loop()
	final_score.text = "SCORE %d" % score
	final_reality.text = "%s %d" % [LocalizationManager.tr_key("round"), round]
	game_over_menu.visible = true
	restart_button.grab_focus()

func _on_quit_pressed() -> void:
	AudioManager.play_click()
	get_tree().quit()

func _on_restart_pressed() -> void:
	AudioManager.play_click()
	get_tree().paused = false
	game_over_menu.visible = false
	get_tree().reload_current_scene()
	
func update_upgrade_hud():
	if player == null:
		return

	var upgrades = player.upgrades

	var spread_count = upgrades.get("spread_shot", 0)
	var speed_count = upgrades.get("speed_up", 0)
	var fire_rate_count = upgrades.get("fire_rate", 0)
	#var shield_count = upgrades.get("shield", 0)
	var shield_count = player.shield_charges

	spread_label.text = "x%d" % spread_count
	speed_label.text = "x%d" % speed_count
	fire_rate_label.text = "x%d" % fire_rate_count
	shield_label.text = "x%d" % shield_count

	spread_box.visible = spread_count > 0
	speed_box.visible = speed_count > 0
	fire_rate_box.visible = fire_rate_count > 0
	shield_box.visible = shield_count > 0	
	
func spawn_boss():
	if boss_scene == null:
		return

	if boss_spawned:
		return

	boss_spawned = true
	AudioManager.switch_to_boss_bgm(boss_bgm)

	if spawn_manager != null and spawn_manager.has_method("stop_spawning"):
		spawn_manager.stop_spawning()

	var boss = boss_scene.instantiate()
	boss.hp *= hp_multiplier
	add_child(boss)
	boss.global_position = Vector2(get_viewport_rect().size.x / 2, -120)

	boss.horizontal_speed = get_boss_horizontal_speed_for_round()
	boss.stop_y = get_boss_stop_y_for_round()

	if boss.has_method("set_movement_origin"):
		boss.set_movement_origin()

	show_boss_health(boss.hp, "AZATOTH")

	if boss.has_signal("boss_health_changed"):
		boss.boss_health_changed.connect(_on_boss_health_changed)

	if boss.has_signal("boss_defeated"):
		boss.boss_defeated.connect(_on_boss_defeated)
		
func _on_boss_defeated():
	hide_boss_health()
	boss_spawned = false
	AudioManager.switch_to_bgm(level_bgm)
	await start_next_round()
	
func show_boss_health(max_hp: int, boss_name: String = "AZATOTH"):
	boss_health_hud.visible = true
	boss_name_label.text = boss_name
	boss_health_bar.max_value = max_hp
	boss_health_bar.value = max_hp

func update_boss_health(current_hp: int):
	boss_health_bar.value = current_hp

func hide_boss_health():
	boss_health_hud.visible = false
	
func _on_boss_health_changed(current_hp, max_hp):
	update_boss_health(current_hp)	

func increase_difficulty():
	round += 1

	hp_multiplier += 0.3
	speed_multiplier += 0.1

	print("Round:", round)
	print("HP Mult:", hp_multiplier)
	print("Speed Mult:", speed_multiplier)
	
func fade_to_black():
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.5)
	await tween.finished

func fade_from_black():
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.5)
	await tween.finished
	
func start_next_round():
	await fade_to_black()

	reset_level_state()
	increase_difficulty()

	await fade_from_black()
	round_label.text = "%s %d" % [LocalizationManager.tr_key("round"), round]
	round_label.visible = true
	await get_tree().create_timer(3.0, false).timeout
	round_label.visible = false
	start_spawning()
	schedule_boss_spawn(60.0)
	
func reset_level_state():
	# remove todos os inimigos existentes
	for child in get_children():
		if child.is_in_group("enemies"):
			child.queue_free()

	# opcional: remover tiros inimigos também
	for child in get_children():
		if child.is_in_group("enemy_bullets"):
			child.queue_free()
			
func start_spawning():
	if spawn_manager != null:
		spawn_manager.start_spawning()
		
func schedule_boss_spawn(delay: float = 60.0):

	if boss_spawn_in_progress:
		return

	boss_spawn_in_progress = true
	call_deferred("_start_boss_spawn_timer", delay)
	
func _start_boss_spawn_timer(delay: float):
		
	#await get_tree().create_timer(delay).timeout
	await get_tree().create_timer(delay, false).timeout
	
	if not boss_spawned:
		spawn_boss()

	boss_spawn_in_progress = false
	
func get_boss_horizontal_speed_for_round() -> float:
	return boss_base_horizontal_speed + ((round - 1) * boss_speed_per_round)

func get_boss_stop_y_for_round() -> float:
	var max_stop_y = get_viewport_rect().size.y * boss_max_stop_y_ratio
	var desired_stop_y = boss_base_stop_y + ((round - 1) * boss_stop_y_per_round)

	return min(desired_stop_y, max_stop_y)	
	
func get_enemy_bullet_speed_for_round() -> float:
	return enemy_bullet_base_speed + ((round) * enemy_bullet_speed_per_round)
	
func get_enemy_fire_interval_for_round() -> float:
	return max(
		enemy_fire_interval_min,
		enemy_fire_interval_base - ((round - 1) * enemy_fire_interval_reduction_per_round)
	)

func get_boss_fire_interval_for_round() -> float:
	return max(
		boss_fire_interval_min,
		boss_fire_interval_base - ((round - 1) * boss_fire_interval_reduction_per_round)
	)		
