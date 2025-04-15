extends Node

# Define the save file directory
var save_file_directory = "user://saves/"

# Function to ensure the save directory exists
func ensure_save_directory():
	var dir = DirAccess.open(save_file_directory)
	if not dir:
		dir = DirAccess.open("user://")
		dir.make_dir_recursive("saves")  # Create the "saves" directory
		print("Save directory created.")
	else:
		print("Save directory already exists.")

# Function to delete the oldest save if there are more than 3 saves
func delete_oldest_save_if_needed():
	var dir = DirAccess.open(save_file_directory)

	if dir:
		var save_files = []
		dir.list_dir_begin()

		while true:
			var file_name = dir.get_next()
			if file_name == "":
				break  # No more files

			# Only consider .json save files
			if file_name.ends_with(".json"):
				var file_path = save_file_directory + file_name
				save_files.append({ "name": file_name, "mtime": FileAccess.get_modified_time(file_path) })

		dir.list_dir_end()

		# If there are more than 3 save files, delete the oldest one
		if save_files.size() > 3:
			# Sort by modification time (oldest first)
			save_files.sort_custom(func(a, b):
				return a["mtime"] < b["mtime"]
			)

			# Delete the oldest file
			var oldest_save = save_files[0]["name"]
			var oldest_save_path = save_file_directory + oldest_save
			
			# Delete using DirAccess
			if dir.remove(oldest_save_path) == OK:
				print("Deleted the oldest save: " + oldest_save)
			else:
				print("Failed to delete the oldest save: " + oldest_save)

# Function to save game data with a player-specified save name
func save_game(save_name: String):
	ensure_save_directory()
	var save_file_path = save_file_directory + save_name + ".json"
	Inventory.on_save_serialize()
	var temp_save = Inventory.serialized_upgrades
	var save_data = {
		"fish": Inventory.fish,
		"upgrade_objects": Inventory.upgrade_objects,
		"serialized_upgrade": temp_save,
		"upgrade_items": Inventory.upgrades,
		"meta_upgrades": Inventory.meta_upgrades,
		"currency": Inventory.currency,
		"level": Inventory.level,
		"current_xp": Inventory.current_xp,
		"first_load": Inventory.first_load,
		"has_tutorial": Inventory.has_tutorial,
		"Total Fish": Inventory.total_fish_caught
	}

	# Create a new file instance and open the file for writing
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if file:
		var json_data = JSON.stringify(save_data)
		file.store_string(json_data)
		file.close()
		print("Game saved as " + save_name)

		# After saving, check if there are more than 3 saves and delete the oldest one
		delete_oldest_save_if_needed()
	else:
		print("Failed to open save file for writing")

func load_game(save_name: String):
	var save_file_path = save_file_directory + save_name + ".json"

	if not FileAccess.file_exists(save_file_path):
		print("Save file does not exist: " + save_name)
		return  # Exit the function if the save file doesn't exist

	var file = FileAccess.open(save_file_path, FileAccess.READ)
	if file:
		var json_data = file.get_as_text()
		file.close()  # Close the file after reading

		# Parse the JSON string
		var result = JSON.parse_string(json_data)

		# Check if the parsing was successful by comparing against ERR_PARSE_ERROR
		if result == null:
			print("Failed to parse JSON data.")
			return

		# Check if the result is a dictionary
		if typeof(result) == TYPE_DICTIONARY:
			var loaded_data = result

			# Safely get the values with defaults if the keys don't exist
			Inventory.fish = loaded_data.get("fish", [])
			Inventory.serialized_upgrades = loaded_data.get("serialized_upgrade", [])
			Inventory.upgrade_objects = loaded_data.get("upgrade_objects", [])
			Inventory.upgrades = loaded_data.get("upgrade_items", [])
			Inventory.meta_upgrades = loaded_data.get("meta_upgrades", [])
			Inventory.currency = loaded_data.get("currency", 0)
			Inventory.level = loaded_data.get("level", 1)
			Inventory.current_xp = loaded_data.get("current_xp", 0)
			Inventory.first_load = loaded_data.get("first_load", 0)
			Inventory.has_tutorial = loaded_data.get("has_tutorial", false)
			Inventory.total_fish_caught = loaded_data.get("Total Fish",1)

			Inventory.on_load_deseriealize()
			print("Game loaded successfully from " + save_name)
		else:
			print("Loaded data is not a dictionary.")
	else:
		print("Save file could not be opened")
		
func load_most_recent_save():
	var dir = DirAccess.open(save_file_directory)
	if dir:
		var save_files = []
		dir.list_dir_begin()
		while true:
			var file_name = dir.get_next()
			if file_name == "":
				break
			if file_name.ends_with(".json"):
				var file_path = save_file_directory + file_name
				save_files.append({ "name": file_name, "mtime": FileAccess.get_modified_time(file_path) })
		dir.list_dir_end()
		
		if save_files.size() > 0:
			save_files.sort_custom(func(a, b):
				return a["mtime"] > b["mtime"]
			)
			var most_recent_save = save_files[0]["name"]
			load_game(most_recent_save.substr(0, most_recent_save.length() - 5))  # Strip .json extension
			print("Loaded most recent save: " + most_recent_save)
		else:
			print("No save files found.")
			
func get_most_recent_save_name() -> String:
	print("Checking for most recent save...")
	var dir = DirAccess.open(save_file_directory)
	if dir:
		var save_files = []
		dir.list_dir_begin()
		while true:
			var file_name = dir.get_next()
			if file_name == "":
				break
			# Only consider .json save files
			if file_name.ends_with(".json"):
				var file_path = save_file_directory + file_name
				save_files.append({ "name": file_name, "mtime": FileAccess.get_modified_time(file_path) })
		dir.list_dir_end()
		
		if save_files.size() > 0:
			# Sort save files by modification time (most recent first)
			save_files.sort_custom(func(a, b):
				return a["mtime"] > b["mtime"]
			)
			# Return the name of the most recent save (without .json extension)\
			print("Attempting most recent save: " + str(save_files[0]["name"].substr(0, save_files[0]["name"].length() - 5)))
			return save_files[0]["name"].substr(0, save_files[0]["name"].length() - 5)
		else:
			print("No save files found.")
			return ""  # Explicitly return an empty string if no save files are found
	else:
		print("Failed to open save directory.")
		return ""  # Explicitly return an empty string if the directory fails to open

