extends CanvasLayer

@onready var resume_button = $PausePanel/MarginContainer/VBoxContainer/resume
@onready var quit_button = $PausePanel/MarginContainer/VBoxContainer/quit
@export var shoot : AudioStream


func _ready():
	visible = false
	update_texts()
	if not LocalizationManager.language_changed.is_connected(update_texts):
		LocalizationManager.language_changed.connect(update_texts)

func pause():
	visible = true
	get_tree().paused = true
	AudioManager.stop_weapon_loop()
	resume_button.grab_focus()

func resume():
	AudioManager.play_click()
	get_tree().paused = false
	AudioManager.start_weapon_loop(shoot)
	visible = false
	#get_tree().change_scene_to_file("res://scenes/level/level.tscn")

func _on_resume_pressed() -> void:
	resume()

func _on_resume_focus_entered() -> void:
	AudioManager.play_hover()

func _on_quit_pressed() -> void:
	AudioManager.play_click()
	get_tree().paused = false
	AudioManager.stop_weapon_loop()
	AudioManager.stop_bgm()
	visible = false
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")

func _on_quit_focus_entered() -> void:
	AudioManager.play_hover()

func update_texts():
	resume_button.text = LocalizationManager.tr_key("menu_resume")
	quit_button.text = LocalizationManager.tr_key("menu_quit")
