extends Control

var recipes = {}

func _ready():
	load_craftable_items()

func load_craftable_items():
	var dir = DirAccess.open("res://Objects/Craftable")
	if not dir:
		#print("❌ Could not open Craftable directory")
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name.ends_with(".tscn"):
			var path = "res://Objects/Craftable/" + file_name
			var scene = load(path)

			if scene:
				var instance = scene.instantiate()

				if instance.has_method("get_script"):  # Ensure it's a script-bearing node
					var item_name = file_name.get_basename()  # e.g. "basic_rod"
					var recipe = instance.crafting_recipe
					var readable_name = instance.item_name

					if instance.isCraftable and InventoryManager.level >= instance.required_crafting_level:
						recipes[item_name] = {
							"ingredients": recipe,
							"result": readable_name
						}
						#print("✅ Loaded recipe for:", item_name)
					else:
						pass#print("⚠️ Skipped non-craftable item:", item_name)
				else:
					pass#print("❌ No script attached to:", file_name)
		file_name = dir.get_next()

	dir.list_dir_end()


func get_recipe(item_name: String) -> Dictionary:
	if recipes.has(item_name):
		return recipes[item_name]["ingredients"]
	#print("❌ No recipe found for:", item_name)
	return {}

func can_craft(item_name: String, inventory: Dictionary) -> bool:
	if not recipes.has(item_name):
		#print("❌ ERROR: Recipe does not exist for:", item_name)
		return false

	var recipe = recipes[item_name]["ingredients"]

	for ingredient in recipe.keys():
		if not inventory.has(ingredient):  # ✅ Check by item name
			#print("❌ Not enough materials for:", ingredient)
			#print("🛠 Inventory keys:", inventory.keys())  # Debugging
			return false

		if inventory[ingredient].quantity < recipe[ingredient]:  # ✅ Check quantity
			#print("❌ Not enough quantity of:", ingredient)
			return false

	return true

func craft(item_name: String, inventory_manager):
	if not can_craft(item_name, inventory_manager.InventoryStorage):
		print("Cannot craft", item_name)
		return

	var recipe = recipes[item_name]["ingredients"]

	# Remove required ingredients
	for ingredient in recipe.keys():
		print("🛠 Ingredients to remove for", item_name, ":", recipe.keys())
		SignalBus.InventoryUpdate.emit("Remove", ingredient, 1)

	# Add crafted item
	print("CRAFTING")
	SignalBus.emit_signal("InventoryUpdate", "Add", load("res://Objects/Craftable/" + item_name + ".tscn"), 1)
	DialogOrchestrator.check_condition.emit()

	print("Crafted:", item_name)
