extends Node

signal dialog_started
signal dialog_ended

var active = false

var ui = null setget _set_ui #Переданное этой переменной значение передается в сеттер функцию
var quests = null setget _set_quests #Переданное этой переменной значение передается в сеттер функцию

func show_dialog(text:Array):
	if is_instance_valid(ui):
		ui.show_dialog(text)

func quest_visibility(name:String, visible:bool):
	if is_instance_valid(quests):
		quests.quest_visibility(name, visible)

func quest_marker(name:String, enabled:bool):
	if is_instance_valid(quests):
		quests.quest_marker(name, enabled)

func quest_delete(name:String):
	if is_instance_valid(quests):
		quests.quest_delete(name)

func quest_start(name:String, par:String):
	if is_instance_valid(quests):
		quests.quest_start(name, par)

func _set_ui(node):
	if not node is Node:
		push_error("provided node doesn't extend Node")
		return
	
	ui = node
	
	if ui.get_script().has_script_signal("dialog_started"):
		ui.connect("dialog_started", self, "_on_dialog_started")
	else:
		push_error("provided node doesn't implement dialog_started signal")
	
	if ui.get_script().has_script_signal("dialog_ended"):
		ui.connect("dialog_ended", self, "_on_dialog_ended")
	else:
		push_error("provided node doesn't implement dialog_started signal")
	
	pass
	
func _set_quests(node):
	if not node is Node:
		push_error("provided node doesn't extend Node")
		return
	
	quests = node

func _on_dialog_started():
	active = true
	emit_signal("dialog_started")
	
func _on_dialog_ended():
	active = false
	emit_signal("dialog_ended")
