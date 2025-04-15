extends Node

var master_data = {}
var character_state = {}

func _ready():
    load_master_data("res://characters/master_character_index.json")

func load_master_data(master_path: String):
    var file = FileAccess.open(master_path, FileAccess.READ)
    var index = JSON.parse_string(file.get_as_text())

    for char_name in index.keys():
        var data_path = index[char_name]["data"]
        var character_data = load_character_data(data_path)
        master_data[char_name] = character_data

func load_character_data(path: String) -> Dictionary:
    var file = FileAccess.open(path, FileAccess.READ)
    var json = JSON.parse_string(file.get_as_text())
    var base_path = path.get_base_dir() + "/"

    if json.has("icon") and not json["icon"].begins_with("res://"):
        json["icon"] = base_path + json["icon"]

    for set_id in json.get("dialog_sets", {}).keys():
        var relative_path = json["dialog_sets"][set_id]
        if not relative_path.begins_with("res://"):
            json["dialog_sets"][set_id] = base_path + relative_path

    return json

func get_dialog_set_path(character: String, set_id: String) -> String:
    return master_data[character]["dialog_sets"].get(set_id, "")

func has_flag(character: String, flag: String) -> bool:
    return character_state[character]["flags"].get(flag, false)

func set_flag(character: String, flag: String):
    character_state[character]["flags"][flag] = true

func add_friendship(character: String, amount: int):
    character_state[character]["friendship_level"] += amount

func get_friendship(character: String) -> int:
    return character_state[character]["friendship_level"]
