extends Node

signal dialog_continue()
signal dialog_started(set_id)
signal dialog_ended(set_id)
signal broadcast_condition(condition,blink)
signal check_condition()

var current_condition = ""
var condition_was_met = false

var dialog_active = true
var current_connected_signal = ""
var DialogUI: Node = null

var wait_condition_met

var dialog_set = {}
var current_index = 0
var active_set_id = ""
var is_waiting = false
var current_character = ""

func _ready():
	connect("check_condition",Callable(self,"recheck"))
	SignalBus.connect("InventoryUpdate", Callable(self, "_on_inventory_updated"))
	DialogUI = get_tree().get_root().find_child("DialogUI", true, false)
	if DialogUI == null:
		pass#print("❌ DialogUI not found")

func recheck():
	_check_condition(current_condition)


func start_dialog_set(character: String, set_id: String):
	
	DialogUI = get_tree().get_current_scene().find_child("DialogUI", true, false)

	dialog_active = true
	SignalBus.DialogStatus.emit("Active")
	DialogUI.show()
	current_character = character
	var path = CharacterManager.get_dialog_set_path(character, set_id)
	dialog_set = _load_set(path)
	current_index = 0
	active_set_id = dialog_set["id"]

	if CharacterManager.has_flag("global", dialog_set.get("completed_flag", "")):
		return
	var dialog_id = dialog_set.get("id", "")
	if dialog_id != "" and DialogManager.is_dialog_completed(dialog_id):
		#print("Dialog", dialog_id, "already completed, skipping.")
		return  # Skip dialog if already completed
	emit_signal("dialog_started", active_set_id)
	_next_step()

func _load_set(path: String) -> Dictionary:
	pass#print("📁 Trying to load dialog file at:", path)

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("❌ File not found or could not be opened: " + path)
		return {}

	var text := file.get_as_text()
	if text == "":
		push_error("⚠️ File is empty: " + path)
		return {}

	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("⚠️ Failed to parse dialog JSON at: " + path)
		return {}

	return parsed


func wait_for_continue():
	is_waiting = true
	wait_condition_met = false
	connect("dialog_continue", Callable(self, "_on_wait_condition_completed"), CONNECT_ONE_SHOT)

	while not wait_condition_met:
		await get_tree().process_frame

	is_waiting = false


func _next_step():
	DialogUI = get_tree().get_root().find_child("DialogUI", true, false)
	if dialog_active:
		DialogUI.show()
	else:
		DialogUI.hide()

	#print("➡️ _next_step called, current_index:", current_index)

	if current_index >= dialog_set["sequence"].size():
		SignalBus.DialogStatus.emit("done")
		_end_set()
		return

	var step = dialog_set["sequence"][current_index]

	# ✅ Prevent duplicate action execution by marking it FIRST
	if step.has("action_before") and step["action_before"] != "" and not step.get("has_run_action", false):
		step["has_run_action"] = true

		var actions = step["action_before"].split(";")
		for action in actions:
			_do_action(action.strip_edges())


	# ✅ Show the dialog line
	var portrait_texture = CharacterManager.get_portrait(step["speaker"])
	DialogUI.display_line(step["speaker"], step["text"], portrait_texture)
		# Check and broadcast condition immediately if present
	if step.has("condition") and step["condition"] != "":
		await get_tree().process_frame  # wait one frame
		_check_condition(step["condition"])


	is_waiting = true


	# ✅ Clean up previous signal connection
	if current_connected_signal != "" and is_connected(current_connected_signal, Callable(self, "_on_wait_condition_completed")):
		disconnect(current_connected_signal, Callable(self, "_on_wait_condition_completed"))

	# ✅ Pick signal to wait for
	current_connected_signal = step.get("wait_for", "dialog_continue")

	if not is_connected(current_connected_signal, Callable(self, "_on_wait_condition_completed")):
		connect(current_connected_signal, Callable(self, "_on_wait_condition_completed"))

	#print("🔌 Connected to signal:", current_connected_signal)




func _connect_step_signal():
	#print("🔌 Connected to signal:", current_connected_signal)
	connect(current_connected_signal, Callable(self, "_on_wait_condition_completed"))



func _check_condition(condition_str: String) -> bool:
	current_condition = condition_str
	var parts = condition_str.split(":")
	var cmd = parts[0]
	var arg = parts[1] if parts.size() > 1 else ""
	match cmd:
		"has_item":
			#print("🧪 Inventory keys:", InventoryManager.InventoryStorage.keys())
			#print("🔍 Looking for item_name:", arg)
			if InventoryManager.get_item_amount(arg) <= 0:
				broadcast_condition.emit("You need " + arg + " to advance!", false)
				condition_was_met = false  # 🔁 reset so sound can play again later
			else:
				broadcast_condition.emit("Press F to advance!", true)
				if not condition_was_met:
					SoundEffects.play()
					condition_was_met = true
			return InventoryManager.get_item_amount(arg) > 0
		"flag_set":
			return CharacterManager.has_flag("global", arg)

	#print("⚠️ Unknown condition:", condition_str)
	return false



func _unhandled_input(event):
	if dialog_active and is_waiting and event.is_action_pressed("f"):
		#print("F")
		#print(current_connected_signal)
		emit_signal("dialog_continue")

func _on_inventory_updated(_op, _item, _quantity = 1):
	if dialog_active:
		#print("Dialog says inventory update")
		#print("Current index:", current_index)
		#print("Is waiting:", is_waiting)
		#print("Current step:", dialog_set["sequence"][current_index])
		#print("Dialog says inventory update")
		if current_index >= dialog_set["sequence"].size():
			return

		var step = dialog_set["sequence"][current_index]
		if step.has("condition"):
			if _check_condition(step["condition"]):
				#print("✅ Condition now met on inventory update!")
				if is_waiting:
					trigger_condition(current_connected_signal)




func _on_wait_condition_completed():
	pass#print("✅ _on_wait_condition_completed triggered from signal:", current_connected_signal)

	# Check current step condition before moving forward
	var step = dialog_set["sequence"][current_index]
	if step.has("condition") and step["condition"] != "":
		if not _check_condition(step["condition"]):
			#print(step["condition"])
			#print("⛔ Condition not met, cannot advance")
			return  # Don't continue yet

	# Continue as normal
	if current_connected_signal != "" and is_connected(current_connected_signal, Callable(self, "_on_wait_condition_completed")):
		disconnect(current_connected_signal, Callable(self, "_on_wait_condition_completed"))

	current_connected_signal = ""
	is_waiting = false
	current_index += 1
	_next_step()




func trigger_condition(condition: String):
	if is_waiting:
		emit_signal(condition)

func _end_set():
	var dialog_id = dialog_set.get("id", "")
	if dialog_id != "":
		DialogManager.complete_dialog(dialog_id)
	dialog_active = false
	var flag = dialog_set.get("completed_flag", "")
	
	if flag != "":
		CharacterManager.set_flag("global", flag)
	emit_signal("dialog_ended", active_set_id)
	SignalBus.DialogStatus.emit("done")
	condition_was_met = false

func find_node_anywhere(name: String) -> Node:
	for node in get_tree().get_root().get_children():
		var found = node.find_child(name, true, false)
		if found:
			return found
	return null

func _do_action(action_str: String):
	#print(">>> _do_action called:", action_str)
	var parts = action_str.split(":")
	var cmd = parts[0]
	var arg = parts[1] if parts.size() > 1 else ""

	match cmd:
		"give_item":
			var item_name = ""
			var quantity = 1

			# Support "Wood 2" or just "Wood"
			var subparts = arg.strip_edges().split(" ")
			if subparts.size() > 0:
				item_name = subparts[0]
			if subparts.size() > 1:
				quantity = int(subparts[1])

			#print("Emitting InventoryUpdate to add:", item_name, "x", quantity)
			SignalBus.InventoryUpdate.emit("Add", item_name, quantity)
		"show":
			var subparts = arg.strip_edges().split(" ")
			if subparts.size() > 0:
				arg = subparts[0]
			var toShow = get_tree().get_root().find_child(arg, true, false)
			toShow.visible = true
			
		"hide":
			var subparts = arg.strip_edges().split(" ")
			if subparts.size() > 0:
				arg = subparts[0]

			var toShow = find_node_anywhere(arg)
			if toShow:
				toShow.visible = false
			else:
				pass#print("⚠️ Couldn't find node with name:", arg)
			
		"startquest":
			print("Starting quest:", arg)
			if QuestManager.has_method("start_quest"):
				QuestManager.start_quest(arg)
			else:
				pass#print("QuestManager missing method: start_quest")

		"finishquest":
			#print("Finishing quest:", arg)
			if QuestManager.has_method("finish_quest"):
				QuestManager.finish_quest(arg)
			else:
				pass#print("QuestManager missing method: finish_quest")

