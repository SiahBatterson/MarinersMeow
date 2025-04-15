extends Node

var master_data = {}
var character_state = {}

func _ready():
	load_master_data("res://Dialog System/characters/master_character_index.json")

func load_master_data(master_path: String):
	print("Trying to open: ", master_path)
	var file = FileAccess.open(master_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open file at: " + master_path)
		return
	var content = file.get_as_text()
	print("File content: ", content) # Temporarily print contents
	var index = JSON.parse_string(content)
	print("Parsed JSON: ", index)

	for char_name in index.keys():
		var data_path = index[char_name]["data"]
		print("Loading character data from: ", data_path)
		var character_data = load_character_data(data_path)
		master_data[char_name] = character_data


func load_character_data(path: String) -> Dictionary:
	print("Attempting to load file at path: ", path)
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Cannot open file at path: " + path)
		return {}
	
	var file_content = file.get_as_text()
	print("Raw JSON content loaded from file:\n", file_content)
	
	var json_result = JSON.parse_string(file_content)
	if typeof(json_result) != TYPE_DICTIONARY:
		push_error("JSON parsing failed or incorrect format at path: " + path)
		return {}

	print("Successfully parsed JSON from: ", path)
	print("JSON Keys: ", json_result.keys())

	var base_path = path.get_base_dir() + "/"

	if json_result.has("icon") and not json_result["icon"].begins_with("res://"):
		json_result["icon"] = base_path + json_result["icon"]

	if json_result.has("dialog_sets"):
		for set_id in json_result["dialog_sets"].keys():
			var relative_path = json_result["dialog_sets"][set_id]
			if not relative_path.begins_with("res://"):
				json_result["dialog_sets"][set_id] = base_path + relative_path
	else:
		push_warning("'dialog_sets' key NOT FOUND in JSON at: " + path)
		json_result["dialog_sets"] = {}

	return json_result



func get_dialog_set_path(character: String, set_id: String) -> String:
	if not master_data.has(character):
		push_error("Character not found in master_data: " + character)
		return ""
	if not master_data[character].has("dialog_sets"):
		push_error("dialog_sets not found for character: " + character)
		return ""
	return master_data[character]["dialog_sets"].get(set_id, "")

func get_portrait(character: String) -> Texture2D:
	if not master_data.has(character):
		return null
	if not master_data[character].has("icon"):
		return null

	var path = master_data[character]["icon"]
	if path != "":
		return load(path)
	return null


func has_flag(character: String, flag: String) -> bool:
	if not character_state.has(character):
		return false
	if not character_state[character].has("flags"):
		return false
	return character_state[character]["flags"].get(flag, false)

func set_flag(character: String, flag: String):
	if not character_state.has(character):
		character_state[character] = {
			"flags": {}
		}
	elif not character_state[character].has("flags"):
		character_state[character]["flags"] = {}

	character_state[character]["flags"][flag] = true


func add_friendship(character: String, amount: int):
	character_state[character]["friendship_level"] += amount

func get_friendship(character: String) -> int:
	return character_state[character]["friendship_level"]
