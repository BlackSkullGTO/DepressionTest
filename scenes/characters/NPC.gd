extends StaticBody2D

export(Texture) var _sprite
export(String, "up", "down", "left", "right") var _facing = "down"

func _ready():
	$sprite.texture = _sprite
	$anims.play("idle_" + _facing)
