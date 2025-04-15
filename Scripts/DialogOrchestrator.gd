extends Node

signal dialog_started(set_id)
signal dialog_ended(set_id)

var dialog_set = {}
var current_index = 0
var active_set_id = ""
var is_waiting = false
var current_character = ""

func start_dialog_set(character: String, set_id: String):
    current_character = character
    var path = CharacterManager.get_dialog_set_path(character, set_id)
    dialog_set = _load_set(path)
    current_index = 0
    active_set_id = dialog_set["id"]

    if CharacterManager.has_flag("global", dialog_set.get("completed_flag", "")):
        return

    emit_signal("dialog_started", active_set_id)
    _next_step()

func _load_set(path: String) -> Dictionary:
    var file = FileAccess.open(path, FileAccess.READ)
    return JSON.parse_string(file.get_as_text())

func _next_step():
    if current_index >= dialog_set["sequence"].size():
        _end_set()
        return

    var step = dialog_set["sequence"][current_index]

    if step.has("action_before"):
        _do_action(step["action_before"])

    DialogUI.display_line(step["speaker"], step["text"])

    if step.has("wait_for"):
        is_waiting = true
        yield(self, step["wait_for"])
        is_waiting = false

    current_index += 1
    _next_step()

func trigger_condition(condition: String):
    if is_waiting:
        emit_signal(condition)

func _end_set():
    var flag = dialog_set.get("completed_flag", "")
    if flag != "":
        CharacterManager.set_flag("global", flag)
    emit_signal("dialog_ended", active_set_id)

func _do_action(action_str: String):
    var parts = action_str.split(":")
    var cmd = parts[0]
    var arg = parts.size() > 1 ? parts[1] : ""

    match cmd:
        "lock_player":
            PlayerController.set_input_enabled(false)
        "unlock_player":
            PlayerController.set_input_enabled(true)
        "open_crafting":
            UIManager.open_crafting()
        "give_item":
            Inventory.add(arg)
        "open_fishing_tip":
            UIManager.show_fishing_tutorial()
