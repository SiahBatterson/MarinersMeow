extends Control

var recipes = {
	"basic_rod": {
		"ingredients": { "Wood": 1, "Fiber": 1 },
		"result": "Basic Rod"
	},
	"unique_sword": {
		"ingredients": { "basic_sword": 1, "wood": 1 },
		"result": "Unique Sword"
	},
	"torch": {
		"ingredients": { "Wood": 3},
		"result": "torch"
	}
}

func get_recipe(item_name: String) -> Dictionary:
	if recipes.has(item_name):
		return recipes[item_name]["ingredients"]
	print("❌ No recipe found for:", item_name)
	return {}

func can_craft(item_name: String, inventory: Dictionary) -> bool:
	if not recipes.has(item_name):
		print("❌ ERROR: Recipe does not exist for:", item_name)
		return false

	var recipe = recipes[item_name]["ingredients"]

	for ingredient in recipe.keys():
		if not inventory.has(ingredient):  # ✅ Check by item name
			print("❌ Not enough materials for:", ingredient)
			print("🛠 Inventory keys:", inventory.keys())  # Debugging
			return false

		if inventory[ingredient].quantity < recipe[ingredient]:  # ✅ Check quantity
			print("❌ Not enough quantity of:", ingredient)
			return false

	return true

func craft(item_name: String, inventory_manager):
	if not can_craft(item_name, inventory_manager.InventoryStorage):
		print("Cannot craft", item_name)
		return

	var recipe = recipes[item_name]["ingredients"]

	# Remove required ingredients
	for ingredient in recipe.keys():
		SignalBus.emit_signal("InventoryUpdate", "Remove", ingredient)

	# Add crafted item
	
	SignalBus.emit_signal("InventoryUpdate", "Add", load("res://Objects/" + item_name + ".tscn"))

	print("Crafted:", item_name)
