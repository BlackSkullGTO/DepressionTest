extends Control

func _ready():
	grab_focus()

func _on_new_game_pressed():
	Globals.custom_variables.clear()
	get_tree().change_scene("res://scenes/levels/NewGame.tscn")
	pass

func _on_quit_pressed():
	get_tree().quit()
	pass
