extends Node2D

@onready var pause_menu = $PauseMenu
@onready var score_label = $scorelayer/scorelabel
@onready var game_over_menu = $gameover
@onready var restart_button = $gameover/gameoverpanel/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/restart
@onready var quit_button = $gameover/gameoverpanel/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/quit

var score := 0

func update_texts():

	pause_menu.resume_button.text = LocalizationManager.tr_key("menu_resume")
	pause_menu.quit_button.text = LocalizationManager.tr_key("menu_quit")
	restart_button = LocalizationManager.tr_key("menu_restart")
	quit_button = LocalizationManager.tr_key("menu_quit")
	# adicione outros botões aqui

func _ready() -> void:
	update_score_ui()
	game_over_menu.visible=false
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
