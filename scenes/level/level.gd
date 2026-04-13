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

var boss_spawned := false

var score := 0

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
		
	await get_tree().create_timer(60.0).timeout
	spawn_boss()		
			
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
	get_tree().paused
	game_over_menu.visible = true
	restart_button.grab_focus()

func _on_quit_pressed() -> void:
	AudioManager.play_click()
	get_tree().quit()

func _on_restart_pressed() -> void:
	AudioManager.play_click()
	game_over_menu.visible = true
	get_tree().reload_current_scene()
	
func update_upgrade_hud():
	if player == null:
		return

	var upgrades = player.upgrades

	var spread_count = upgrades.get("spread_shot", 0)
	var speed_count = upgrades.get("speed_up", 0)
	var fire_rate_count = upgrades.get("fire_rate", 0)
	var shield_count = upgrades.get("shield", 0)

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
	AudioManager.play_boss()

	if spawn_manager != null and spawn_manager.has_method("stop_spawning"):
		spawn_manager.stop_spawning()

	var boss = boss_scene.instantiate()
	add_child(boss)
	boss.global_position = Vector2(get_viewport_rect().size.x / 2, -120)

	if boss.has_method("set_movement_origin"):
		boss.set_movement_origin()

	show_boss_health(boss.hp, "AZATOTH")

	if boss.has_signal("boss_health_changed"):
		boss.boss_health_changed.connect(_on_boss_health_changed)

	if boss.has_signal("boss_defeated"):
		boss.boss_defeated.connect(_on_boss_defeated)
		
func _on_boss_defeated():
	hide_boss_health()
	print("Boss derrotado!")
	
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
