extends "res://scenes/misc/Quest.gd"

func start(s):
	var result = 0
	for i in range(20):
		result += int(Globals.custom_variables["test" + str(i + 1)])
	Globals.custom_variables["test_result"] = str(result)
	
	print(result)
	if result < 10:
		Globals.custom_variables["test_result_category"] = "0"
	elif result >= 10 and result < 16:
		Globals.custom_variables["test_result_category"] = "1"
	elif result >= 16 and result < 20:
		Globals.custom_variables["test_result_category"] = "2"
	elif result >= 20 and result < 30:
		Globals.custom_variables["test_result_category"] = "3"
	elif result >= 30:
		Globals.custom_variables["test_result_category"] = "4"
	
	print(Globals.custom_variables["test_result_category"])
