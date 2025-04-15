extends Control

# Reference to SaveGame.gd
@onready var save_game_script = Saveandload  # Reference to your SaveGame.gd script
@onready var save_name_input = $LineEdit  # Reference to the LineEdit for save name input
@onready var save_dropdown = $SaveDropdown  # Reference to the OptionButton for selecting saves
@onready var save_button = $Save  # Reference to the SaveButton
@onready var load_button = $LoadGame  # Reference to the LoadButton

# Populate the dropdown with available saves
func populate_save_dropdown():
	var save_file_directory = "user://saves/"
	var dir = DirAccess.open(save_file_directory)

	if dir:
		save_dropdown.clear()  # Clear any existing items in the dropdown
		dir.list_dir_begin()  # Begin reading the directory
		var file_name = ""
		
		while true:
			file_name = dir.get_next()
			if file_name == "":
				break  # No more files

			# Only add .json save files to the dropdown
			if file_name.ends_with(".json"):
				var save_name = file_name.substr(0, file_name.length() - 5)  # Manually remove .json extension
				save_dropdown.add_item(save_name)  # Add save name to dropdown

		dir.list_dir_end()  # End reading the directory

		# If no saves are found, disable the load button
		if save_dropdown.get_item_count() == 0:
			load_button.disabled = true
			print("No save games found.")
		else:
			#load_button.disabled = false
			save_dropdown.select(0)  # Select the first save by default
	else:
		print("Failed to open save directory")

# Function to save the game using the name entered in the LineEdit
func _on_SaveButton_pressed():
	print("Saving: " + str(Inventory.upgrades))
	var save_name = save_name_input.text.strip_edges()  # Get the save name from LineEdit
	if save_name != "":
		save_game_script.save_game(save_name)  # Call save_game with the entered name
		populate_save_dropdown()  # Refresh the dropdown after saving
	else:
		print("Please enter a valid save name.")

# Function to load the game based on the selected save in the dropdown
func _on_LoadButton_pressed():
	var selected_save = save_dropdown.get_item_text(save_dropdown.get_selected_id())
	if selected_save:
		save_game_script.load_game(selected_save)
		for i in Inventory.meta_upgrades:
			Inventory.check_meta(i)
		get_tree().change_scene_to_file("res://Gameplay Scenes/island_scene.tscn")
	else:
		print("No valid save selected")

func load_most_recent_save():
	print("Attempting to load the most recent save...")
	var selected_save = Saveandload.get_most_recent_save_name()
	if selected_save != "":
		print("Most recent save: " + selected_save)
		Saveandload.load_game(selected_save)
		for i in Inventory.meta_upgrades:
			Inventory.check_meta(i)
		get_tree().change_scene_to_file("res://Gameplay Scenes/island_scene.tscn")
		print("Loaded most recent save: " + selected_save)
	else:
		print("No valid save found to load.")


# Call this function when the scene is ready
func _ready():
	populate_save_dropdown()  # Populate the save dropdown when the scene is ready
