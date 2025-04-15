extends Button

# Reference to SaveGame.gd
@onready var save_game_script = $SaveGame  # Update the path to SaveGame.gd if needed
@onready var save_name_input = $LineEdit   # Reference to the LineEdit where player inputs the save name

# Hook Save button
func _on_SaveButton_pressed():
	var save_name = save_name_input.text.strip_edges()
	if save_name != "":
		save_game_script.save_game(save_name)
	else:
		print("Please enter a valid save name.")

# Hook Load button
func _on_LoadButton_pressed():
	var save_name = save_name_input.text.strip_edges()
	if save_name != "":
		save_game_script.load_game(save_name)
	else:
		print("Please enter a valid save name.")
