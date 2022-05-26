extends "res://scenes/misc/Quest.gd"
export(NodePath) var player_path

func start(s):
	var _player = get_node(player_path)
	_player.change_sex()
