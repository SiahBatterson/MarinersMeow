extends Node

signal quest_started(quest_id)
signal quest_completed(quest_id)

var quests = {}  # Stores all quests
var active_quests = {}

func _ready():
	print("QuestManager initialized")
	load_quests_from_json("res://Dialog System/Questing/Quests/quests.json")


func define_quest(quest_data: Dictionary):
	var quest_id = quest_data.get("id", "")
	if quest_id == "":
		push_error("Quest must have an 'id'")
		return

	quests[quest_id] = quest_data

func load_quests_from_json(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		if data and data.has("quests"):
			for quest in data["quests"]:
				define_quest(quest)


func start_quest(quest_id: String):
	if not quests.has(quest_id):
		push_error("No such quest: " + quest_id)
		return

	var quest = quests[quest_id]
	active_quests[quest_id] = quest.duplicate(true)

	emit_signal("quest_started", quest_id)
	print("Quest started:", quest_id)

func finish_quest(quest_id: String) -> bool:
	if not active_quests.has(quest_id):
		push_error("Quest not active: " + quest_id)
		return false

	var quest = active_quests[quest_id]

	if not _check_conditions(quest):
		print("Conditions not met for quest:", quest_id)
		return false

	_apply_rewards(quest)
	active_quests.erase(quest_id)

	emit_signal("quest_completed", quest_id)
	print("Quest finished:", quest_id)
	return true

func get_dialog_set_for_quest(quest_id: String) -> String:
	var quest = quests.get(quest_id, null)
	return quest.get("dialog_set", "") if quest else ""


func submit_quest(quest_id: String) -> bool:
	if QuestManager.can_submit_quest(quest_id):
		var success = QuestManager.finish_quest(quest_id)
		if success:
			var dialog_set = QuestManager.get_dialog_set_for_quest(quest_id)
			var quest = quests.get(quest_id)
			var character = quest.get("giver", "")

			#DialogOrchestrator.start_dialog_set(character,dialog_set) #FIX LATER
			return true
	else:
		print("Quest not ready to submit.")
	return false


func _check_conditions(quest: Dictionary) -> bool:
	if not quest.has("conditions"):
		return true  # No conditions = auto complete

	for condition in quest["conditions"]:
		var type = condition.get("type", "")
		match type:
			"has_item":
				var item = condition.get("item", "")
				var quantity = condition.get("quantity", 1)
				if not _player_has_item(item, quantity):
					return false
			_:
				print("Unknown condition type:", type)
	return true

func _apply_rewards(quest: Dictionary):
	if not quest.has("rewards"):
		return

	var rewards = quest["rewards"]
	if rewards.has("items"):
		for item in rewards["items"]:
			var name = item.get("item", "")
			var quantity = item.get("quantity", 1)
			SignalBus.InventoryUpdate.emit("Add", name, quantity)  # Or call your inventory system directly

	if rewards.has("money"):
		var amount = rewards["money"]
		print("Reward: Give money", amount)
		InventoryManager.currenyManager("add",amount)

func _player_has_item(item_name: String, quantity: int) -> bool:
	# Replace this with actual inventory lookup
	return (InventoryManager.get_item_amount(item_name)>=quantity)

func can_submit_quest(quest_id: String) -> bool:
	if not active_quests.has(quest_id):
		return false
	return _check_conditions(active_quests[quest_id])


# Example of how a quest could be defined and added
func define_sample_quest():
	define_quest({
		"id": "fetch_wood",
		"giver": "Lumberjack",
		"dialog_set": "lumberjack_intro",
		"conditions": [
			{ "type": "has_item", "item": "Wood", "quantity": 5 }
		],
		"rewards": {
			"items": [
				{ "item": "Axe", "quantity": 1 }
			],
			"money": 100
		}
	})
