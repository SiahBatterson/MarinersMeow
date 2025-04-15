extends Control

@onready var quest_container = $VBoxContainer
@onready var QuestEntryScene = preload("res://Dialog System/Questing/QuestEntry.tscn")

func _ready():
	refresh_quest_log()

func refresh_quest_log():
	for child in quest_container.get_children():
		child.queue_free()


	for quest_id in QuestManager.active_quests.keys():
		var quest_data = QuestManager.active_quests[quest_id]
		var entry = QuestEntryScene.instantiate()
		quest_container.add_child(entry)
		entry.set_quest(quest_data)
