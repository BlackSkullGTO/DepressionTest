extends Node

func _ready():
	Dialogs.quests = self

func quest_visibility(name:String, visible:bool):
	if has_node(name):
		get_node(name).visible = visible
		get_node(name).monitoring = visible

func quest_marker(name:String, enabled:bool):
	if has_node(name):
		get_node(name).marker(enabled)

func quest_delete(name:String):
	if has_node(name):
		get_node(name).queue_free()

func quest_start(name:String, par:String):
	if has_node(name):
		get_node(name).start(par)
