extends KinematicBody2D

class_name Player

export(int) var WALK_SPEED = 750 # pixels per second

var linear_vel = Vector2()

export(String, "up", "down", "left", "right") var facing = "down"

var anim = ""
var new_anim = ""

enum { STATE_BLOCKED, STATE_IDLE, STATE_WALKING }

var female_skin = preload('res://textures//Modern tiles_Free//Female.png')

var state = STATE_IDLE

func _ready():
	if not (
			Dialogs.connect("dialog_started", self, "_on_dialog_started") == OK and
			Dialogs.connect("dialog_ended", self, "_on_dialog_ended") == OK ):
		printerr("Error connecting to dialog system")
	change_sex()
	add_glasses()

func _physics_process(_delta):
	match state:
		STATE_BLOCKED:
			new_anim = "idle_" + facing
			pass
		STATE_IDLE:
			if (
					Input.is_action_pressed("move_down") or
					Input.is_action_pressed("move_left") or
					Input.is_action_pressed("move_right") or
					Input.is_action_pressed("move_up")
				):
					state = STATE_WALKING
			new_anim = "idle_" + facing
			pass
		STATE_WALKING:
			linear_vel = move_and_slide(linear_vel)
			
			var target_speed = Vector2()
			
			if Input.is_action_pressed("move_down"):
				target_speed += Vector2.DOWN
			if Input.is_action_pressed("move_left"):
				target_speed += Vector2.LEFT
			if Input.is_action_pressed("move_right"):
				target_speed += Vector2.RIGHT
			if Input.is_action_pressed("move_up"):
				target_speed += Vector2.UP
			
			target_speed = target_speed.normalized() * WALK_SPEED
			linear_vel = target_speed
			
			_update_facing()
			
			if linear_vel.length() > 5:
				new_anim = "walk_" + facing
			else:
				goto_idle()
			pass
	
	## UPDATE ANIMATION
	if new_anim != anim:
		anim = new_anim
		$anims.play(anim)
	pass

func _on_dialog_started():
	state = STATE_BLOCKED

func _on_dialog_ended():
	state = STATE_IDLE

func goto_idle():
	linear_vel = Vector2.ZERO
	new_anim = "idle_" + facing
	state = STATE_IDLE

func _update_facing():
	if Input.is_action_pressed("move_left"):
		facing = "left"
	if Input.is_action_pressed("move_right"):
		facing = "right"
	if Input.is_action_pressed("move_up"):
		facing = "up"
	if Input.is_action_pressed("move_down"):
		facing = "down"

func change_sex():
	if Globals.custom_variables.has("sex"):
		if Globals.custom_variables["sex"] == 'девочка':
			$sprite.texture = female_skin

func add_glasses():
	if Globals.custom_variables.has("glasses"):
		if Globals.custom_variables["glasses"] == '1':
			$glasses.visible = true
