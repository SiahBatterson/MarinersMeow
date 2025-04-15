extends Node

var completed_dialogs = []

func complete_dialog(dialog_id):
	if dialog_id not in completed_dialogs:
		completed_dialogs.append(dialog_id)

func is_dialog_completed(dialog_id):
	return dialog_id in completed_dialogs

func save():
	var file = FileAccess.open("user://completed_dialogs.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"completed_dialogs": completed_dialogs}))
	file.close()

func load():
	var file = FileAccess.open("user://completed_dialogs.json", FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		completed_dialogs = data["completed_dialogs"]
		file.close()
