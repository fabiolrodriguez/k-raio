extends Node2D

@onready var pause_menu = $PauseMenu


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
	
func toggle_pause():
	if get_tree().paused:
		pause_menu.resume()
		#menu_panel.visible = true
	else:
		pause_menu.pause()
		#menu_panel.visible = false
