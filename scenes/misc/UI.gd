extends CanvasLayer

var dialog_script = []
var dialog_index = 0
var lines_to_skip = 0
var waiting_for_answer = false
var input_variable = ''
var button_scene = preload('res://scenes//misc//OptionButton.tscn')

# warning-ignore:unused_signal
signal dialog_started
# warning-ignore:unused_signal
signal dialog_ended

func _ready():
	Dialogs.ui = self
	$dialog_box.hide()
	pass

func show_dialog(text:Array):
	dialog_script = text
	dialog_index = 0
	$anims.play("dialog_appear")
	pass
	
func next_dialog():
	print(dialog_index)
	if dialog_index < dialog_script.size():
		event_handler(dialog_script[dialog_index])
	else:
		$anims.play("dialog_disappear") #В нем ещё посылаем сигнал dialog_ended

func event_handler(event):
	match event:
		{'text'}, {'text', 'name'}:
			update_name(event)
			update_text(event['text'])
			$anims.play("dialog_show_text")
			dialog_index += 1
		{'options', ..}:
			update_options(event)
			waiting_for_answer = true
			$anims.play("options_appear")
			dialog_index += 1
		{'input', ..}:
			update_input(event)
			waiting_for_answer = true
			$anims.play("input_appear")
			dialog_index += 1
		{'background'}:
			update_background(event)
			dialog_index += 1
		{'switch', ..}:
			check_variables(event)
		{'jump'}:
			jump(int(event['jump']))
		{'jump-to'}:
			jump_to(int(event['jump-to']))
		{'scene'}:
			emit_signal("dialog_ended")
			get_tree().change_scene('res:' + event['scene'])
		{'return'}:
			$anims.play("dialog_disappear")
		{'variable-set', 'value'}:
			Globals.custom_variables[event['variable-set']] = event['value']
			jump(1)
		{'variable-increment', 'value'}:
			if !Globals.custom_variables.has(event['variable-increment']):
				Globals.custom_variables[event['variable-increment']] = '0'
			Globals.custom_variables[event['variable-increment']] = str(int(Globals.custom_variables[event['variable-increment']]) + int(event['value']))
			jump(1)
		{'quest', ..}:
			update_quests(event)
			jump(1)

func parse_text(text):
	var end_text = text
	var c_variable
	for g in Globals.custom_variables:
		c_variable = Globals.custom_variables[g]
		end_text = end_text.replace('[' + g + ']', c_variable)
	return end_text

func update_name(event):
	if event.has('name'):
		$dialog_box/dialog_name/text.text = parse_text(event['name'])
		$dialog_box/dialog_name.visible = true
	else:
		$dialog_box/dialog_name.visible = false

func update_text(text):
	$dialog_box/dialog_text.text = parse_text(text)
	lines_to_skip = 0
	$dialog_box/dialog_text.lines_skipped = lines_to_skip
	return

func update_options(event):
	for o in event['options']:
		var button = button_scene.instance()
		button.text = o['label']
		if event.has('variable-set'):
			button.connect("pressed", self, "_on_option_selected", [button, event['variable-set'], o['value']])
		elif event.has('variable-increment'):
			button.connect("pressed", self, "_on_option_selected", [button, event['variable-increment'], int(o['value']), true])
		else:
			button.connect("pressed", self, "_on_option_selected", [button])
		$options.add_child(button)

func reset_options():
	for option in $options.get_children():
		option.queue_free()

func update_input(event):
	$input/LineEdit.text = ''
	$input/LineEdit.placeholder_text = event['input']
	input_variable = event['variable']

func update_background(event):
	if event['background'] == 'none':
		$anims.play("background_disappear")
	else:
		var bg = 'res:' + event['background']
		print(bg)
		print(ResourceLoader.exists(bg))
		if ResourceLoader.exists(bg):
			$background.texture = load(bg)
			$anims.play("background_appear")

func jump(delta:int):
	if delta == 0:
		print('Прыжок не может быть равен нулю!')
		dialog_index += 1
	else:
		if(delta != 1):
			print('Текущий указатель: ', dialog_index, '; Следующий указатель: ', dialog_index + delta)
		dialog_index += delta
		if dialog_index < 0:
			dialog_index = 0
	next_dialog()

func jump_to(index:int):
	if index < 0:
		dialog_index = 0
	elif index == dialog_index:
		printerr('Нельзя прыгать на тот же индекс, на котором был')
	else:
		dialog_index = index
	next_dialog()

func check_variables(event):
	for s in event['switch']:
		if Globals.custom_variables.has(s['variable']):
			if Globals.custom_variables[s['variable']] == s['equal']:
				print('Переменная ', s['variable'], ' = ', s['equal'])
				jump(int(s['jump']))
				return
	if event.has('default-jump'):
		jump(int(event['default-jump']))
	else:
		jump(1)

func update_quests(event):
	if event.has('visibility'):
		Dialogs.quest_visibility(event['quest'], bool(int(event['visibility'])))
	elif event.has('marker'):
		Dialogs.quest_marker(event['quest'], bool(int(event['marker'])))
	elif event.has('delete'):
		Dialogs.quest_delete(event['quest'])
	elif event.has('start'):
		Dialogs.quest_start(event['quest'], event['start'])

func _input(event):
	if event.is_action_pressed("ui_accept"):
		match $anims.assigned_animation:
			"dialog_show_text":
				$anims.play("dialog_wait")
			"dialog_wait":
				lines_to_skip += 3
				if lines_to_skip < $dialog_box/dialog_text.get_line_count():
					$dialog_box/dialog_text.lines_skipped = lines_to_skip
					$anims.play("dialog_show_text")
				else:
					if (!waiting_for_answer):
						next_dialog()

func _on_option_selected(button, variable=0, value=0, increment=false):
	if typeof(variable) == TYPE_INT:
		pass
	else:
		if increment:
			if !Globals.custom_variables.has(variable):
				Globals.custom_variables[variable] = '0'
			Globals.custom_variables[variable] = str(int(Globals.custom_variables[variable]) + value)
		else:
			Globals.custom_variables[variable] = value
		print('Выбран ответ: ', button.text, ' со значением = ' , value)
		print('Глобальные переменные: ', Globals.custom_variables)
	
	$anims.play("options_disappear") #Вызывает reset_options и next_dialog
	waiting_for_answer = false

func _on_input_selected():
	if $input/LineEdit.text.empty():
		return
	Globals.custom_variables[input_variable] = $input/LineEdit.text
	print('Введен текст: ', $input/LineEdit.text)
	print('Глобальные переменные: ', Globals.custom_variables)
	
	$anims.play("input_disappear") #Вызывает next_dialog
	waiting_for_answer = false
