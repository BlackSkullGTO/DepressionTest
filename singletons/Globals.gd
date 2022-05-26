extends Node

# warning-ignore:unused_class_variable
var custom_variables = {}

func _ready():
	VisualServer.set_default_clear_color(ColorN("white"))

func save_test(): 
	var save_file = File.new()
	save_file.open("user://savegame.json", File.READ_WRITE)
	var current_date = OS.get_datetime()
	var save_line = {}
	save_line["date"] = (
		str(current_date["day"]) + "-" +
		str(current_date["month"]) + "-" +
		str(current_date["year"]) + " " +
		str(current_date["hour"]) + ":" +
		str(current_date["minute"]) + ":" +
		str(current_date["second"])
	)
	save_line["name"] = custom_variables["name"]
	save_line["test"] = custom_variables["test_result"]
	
	match custom_variables["test_result_category"]:
		"0":
			save_line["test"] = "0-9 - отсутствие депрессивных симптомов"
		"1":
			save_line["test"] = "10-15 - легкая депрессия (субдепрессия)"
		"2":
			save_line["test"] = "16-19 - умеренная депрессия"
		"3":
			save_line["test"] = "20-29 - выраженная депрессия средней тяжести"
		"4":
			save_line["test"] = "30-63 - тяжелая депрессия"
			
	save_file.store_line(to_json(save_line))
	save_file.close()
	pass

func load_tests():
	var save_file = File.new()
	
	if not save_file.file_exists("user://savegame.save"):
		return []
	
	save_file.open("user://savegame.save", File.READ)
	
	var save_line = parse_json(save_file.get_line())
	if typeof(save_line) != TYPE_DICTIONARY:
		return []
	
	save_file.close()
	return []
