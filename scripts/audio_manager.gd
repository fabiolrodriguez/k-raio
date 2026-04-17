extends Node

var hover_sound = preload("res://assets/audio/ui/button_hover.mp3")
var click_sound = preload("res://assets/audio/ui/button_click.mp3")
var bg_music = preload("res://assets/audio/music/piano-bg.mp3")
var shoot = preload("res://assets/audio/game/shot.mp3")
var explode = preload("res://assets/audio/game/dead.mp3")
var boss = preload("res://assets/audio/game/boss.mp3")
var boss_died = preload("res://assets/audio/game/boss_died.mp3")

var weapon_loop_player: AudioStreamPlayer

@onready var bgm_player = AudioStreamPlayer

@onready var player = AudioStreamPlayer.new()

@onready var boss_bgm = AudioStreamPlayer

func _ready():
	add_child(player)
	
	boss_bgm = AudioStreamPlayer.new()
	add_child(boss_bgm)
	
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	
	weapon_loop_player = AudioStreamPlayer.new()
	add_child(weapon_loop_player)

func play_hover():
	player.stream = hover_sound
	player.play()

func play_click():
	player.stream = click_sound
	player.play()
	
func play_shoot():
	player.stream = shoot
	player.play()

func play_explode():
	player.volume_db = -2.0
	player.stream = explode
	player.play()
	
func play_boss():
	player.stream = boss
	player.play()
	
func play_boss_died():
	player.stream = boss_died
	player.play()		

func start_weapon_loop(sound: AudioStream):
	if sound == null:
		return

	if weapon_loop_player.stream != sound:
		weapon_loop_player.stream = sound

	if not weapon_loop_player.playing:
		weapon_loop_player.play()

func stop_weapon_loop():
	if weapon_loop_player.playing:
		weapon_loop_player.stop()
		
func play_bgm(music: AudioStream):
	if music == null:
		return

	if bgm_player.stream != music:
		bgm_player.stream = music

	if not bgm_player.playing:
		bgm_player.play()		

func stop_bgm():
	if bgm_player.playing:
		bgm_player.stop()
		
func play_boss_bgm(music: AudioStream):
	if music == null:
		return

	if boss_bgm.stream != music:
		boss_bgm.stream = music

	if not boss_bgm.playing:
		boss_bgm.play()		

func stop_boss_bgm():
	if boss_bgm.playing:
		boss_bgm.stop()
		
func switch_to_bgm(music: AudioStream):
	stop_boss_bgm()
	play_bgm(music)

func switch_to_boss_bgm(music: AudioStream):
	stop_bgm()
	play_boss_bgm(music)
	
func set_bgm_volume(db: float):
	bgm_player.volume_db = db

func set_boss_bgm_volume(db: float):
	weapon_loop_player.volume_db = db	
	
func set_weapon_volume(db: float):
	bgm_player.volume_db = db
