extends "res://scenes/misc/Quest.gd"
export(NodePath) var object_path

func start(visible:String):
	var _object = get_node(object_path)
	if visible == '1':
		_object.visible = true
	else:
		_object.visible = false
