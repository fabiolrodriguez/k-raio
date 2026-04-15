extends Node

var hover_sound = preload("res://assets/audio/ui/button_hover.mp3")
var click_sound = preload("res://assets/audio/ui/button_click.mp3")
var bg_music = preload("res://assets/audio/music/piano-bg.mp3")
var shoot = preload("res://assets/audio/game/shot.mp3")
var explode = preload("res://assets/audio/game/explode.mp3")
var boss = preload("res://assets/audio/game/boss.mp3")

var weapon_loop_player: AudioStreamPlayer

@onready var bgm_player = AudioStreamPlayer.new()

@onready var player = AudioStreamPlayer.new()

func _ready():
	add_child(player)
	add_child(bgm_player)
	
	weapon_loop_player = AudioStreamPlayer.new()
	add_child(weapon_loop_player)

func play_hover():
	player.stream = hover_sound
	player.play()

func play_click():
	player.stream = click_sound
	player.play()


func play_bgm(music: AudioStream):
	if music == null:
		return
	bgm_player.stop()
	bgm_player.stream = music
	bgm_player.play()

func stop_bgm():
	bgm_player.stop()
	
func play_shoot():
	player.stream = shoot
	player.play()

func play_explode():
	player.stream = explode
	player.play()
	
func play_boss():
	player.stream = boss
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
