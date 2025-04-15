extends Node2D

var InventoryStorage = {}
@export var inventorySize = 5
@onready var crafting_manager = $"../CraftingUI"  # Reference to CraftingManager

func _ready():
	SignalBus.connect("InventoryUpdate",Callable(self,"InventoryStorageUpdate"))

func InventoryStorageUpdate(addOrRemove, Item):
	if Item == null:
		print("❌ ERROR: Item is NULL when trying to update inventory!")
		return

	var item_instance
	var item_name = ""

	# ✅ If Item is a PackedScene, instantiate it
	if Item is PackedScene:
		item_instance = Item.instantiate()
		item_name = item_instance.item_name

	# ✅ If Item is a Node and has an `item_name` property, use it
	elif Item is Node and "item_name" in Item:  
		item_instance = Item
		item_name = Item.item_name

	else:
		print("❌ ERROR: Item is not a valid object or PackedScene:", Item)
		return

	print("🛠 Adding to Inventory: Name:", item_name, " | Object:", item_instance)

	if addOrRemove == "Remove":
		if InventoryStorage.has(item_name):
			InventoryStorage[item_name].quantity -= 1
			if InventoryStorage[item_name].quantity <= 0:
				InventoryStorage.erase(item_name)
	elif addOrRemove == "Add":
		if InventoryStorage.has(item_name) and item_instance.is_stackable:
			InventoryStorage[item_name].quantity += 1
		else:
			InventoryStorage[item_name] = {
				"item": item_instance,
				"quantity": 1,
			}

	print("📦 Inventory Keys Now:", InventoryStorage.keys())  # Debugging

func get_item_amount(item_name: String) -> int:
	if InventoryStorage.has(item_name):
		return InventoryStorage[item_name]["quantity"]  # ✅ Get the stored quantity
	return 0  # ✅ Return 0 if the item isn't in inventory


func craft_item(item_name: String):
	if crafting_manager:
		crafting_manager.craft(item_name, self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
