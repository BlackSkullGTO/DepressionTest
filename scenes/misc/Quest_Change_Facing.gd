extends "res://scenes/misc/Quest.gd"
export(String, "up", "down", "left", "right") var facing = "down"

func _on_body_entered(body):
	print("body entered")
	if body is Player:
		active = true
		if (
				!blocked &&
				!dialogs_script.empty() &&
				activation_type == ACTIVATION.enter &&
				!Dialogs.active
			):
			Dialogs.show_dialog(dialogs_script)
			blocked = true
			body._on_dialog_started()
			body.facing = facing
			deactivate()
