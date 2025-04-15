extends Control

var quest_id = ""

@onready var name_label = $QuestName
@onready var description_label = $QuestDescription
@onready var submit_button = $TextureButton

func set_quest(quest_data: Dictionary):
	quest_id = quest_data["id"]
	name_label.text = format_quest_name(quest_id)
	description_label.text = quest_data.get("description", "No description.")
	update_submit_button()


func update_submit_button():
	var can_submit = QuestManager.can_submit_quest(quest_id)
	submit_button.disabled = not can_submit
	submit_button.pressed.connect(_on_submit_pressed)

func _on_submit_pressed():
	QuestManager.submit_quest(quest_id)
	GameManager.fade_out_node_queue(self)

func format_quest_name(raw_id: String) -> String:
	var words = raw_id.split("_")
	for i in range(words.size()):
		words[i] = words[i].capitalize()
	return " ".join(words)


func _on_texture_button_mouse_entered():
	if !QuestManager.submit_quest(quest_id):
		$TextureButton.modulate = Color(1,.8,.8)
		$QuestName.modulate = Color(1,.8,.8)
	if QuestManager.submit_quest(quest_id):
		$QuestName.modulate = Color(1,1,1)
		$TextureButton.modulate = Color(1,1,1)
		


func _on_texture_button_mouse_exited():
	$QuestName.modulate = Color(1,1,1)
	$TextureButton.modulate = Color(1,1,1)
