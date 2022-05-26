extends Area2D

var active = false
var blocked = false

export(String, FILE, "*.json") var dialogs_json = ''
var dialogs_script = ''

enum ACTIVATION {button, enter, ready} #Использовать риди только один раз в сцене!!!
export(ACTIVATION) var activation_type = ACTIVATION.button

enum DEACTIVATION {none, hide, delete} #Hide НЕ РАБОТАЕТ!!! Невозможно изменить параметр monitoring пока в области находится коллайдер. Необходимо вручную отключать и включать все коллайдеры в этом объекте
export(DEACTIVATION) var deactivation_type = DEACTIVATION.none

export(bool) var hided = false

func _ready():
	# warning-ignore:return_value_discarded
	connect("body_entered", self, "_on_body_entered")
	# warning-ignore:return_value_discarded
	connect("body_exited", self, "_on_body_exited")
	
	if hided:
		hide()
		monitoring = false
	
	dialogs_script = file(dialogs_json)
	
	if (
			!dialogs_script.empty() &&
			activation_type == ACTIVATION.ready &&
			!Dialogs.active
		):
		yield(get_tree().create_timer(0.5), "timeout")
		Dialogs.show_dialog(dialogs_script)
		deactivate()

func _input(event):
	if (
			active &&
			!dialogs_script.empty() &&
			activation_type == ACTIVATION.button &&
			event.is_action_pressed("ui_accept") &&
			!Dialogs.active
		):
		Dialogs.show_dialog(dialogs_script)
		deactivate()

func _on_body_entered(body):
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
			deactivate()

func _on_body_exited(body):
	if body is Player:
		active = false
		blocked = false

func deactivate():
	match deactivation_type:
		DEACTIVATION.hide:
			visible = false
		DEACTIVATION.delete:
			queue_free()

func file(file_path):
	var file = File.new()
	var dict = []
	if file.file_exists(file_path):
		file.open(file_path, File.READ)
		var content = file.get_as_text()
		dict = parse_json(content)
		file.close()
		return dict
	else:
		print("File " + file_path + " doesn't exists.")
	return dict

func marker(enabled:bool):
	if enabled:
		$anims.play("marker_appear")
	else:
		$anims.play("marker_disappear")
