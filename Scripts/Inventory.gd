extends Node2D

var InventoryStorage = {}
var currentBalance = 0
var boatIntegrity = 100
var msq_tracker = 0
var UI: Node = null
@onready var inv_notif: PackedScene = preload("res://Objects/inventory_notification.tscn")
const Item = preload("res://Scripts/Item.gd")

var level = 1


@export var inventorySize = 5
var crafting_manager: Node = null  # Reference to CraftingManager

func currenyManager(type,amount):
	if type == "add":
		currentBalance+= amount
	else:
		currentBalance-= amount

func _ready():
	get_tree().connect("current_scene_changed", Callable(self, "_on_scene_changed"))


	crafting_manager = get_tree().get_root().find_child("CraftingUI", true, false)
	UI = get_tree().get_root().find_child("UI_HUD", true, false)
	if crafting_manager == null:
		pass#print("❌ CraftingUI not found!")
	else:
		crafting_manager = crafting_manager.get_node("UI")
		# 🔒 Prevent multiple connections
	if not SignalBus.is_connected("InventoryUpdate", Callable(self, "InventoryStorageUpdate")):
		SignalBus.connect("InventoryUpdate", Callable(self, "InventoryStorageUpdate"))

	if not SignalBus.is_connected("InvVisible", Callable(self, "ShowHide")):
		SignalBus.connect("InvVisible", Callable(self, "ShowHide"))

func boatEvent(kind,extraNumber):
	if kind=="Damage":
		boatIntegrity-=extraNumber
	if kind=="Repair":
		boatIntegrity+= extraNumber

func ShowHide():
	self.visible = !self.visible

func set_ui_reference(node: Node):
	pass#print("✅ UI_HUD registered:", node)
	UI = node


func find_item_by_name_deep(target_name: String, root_path := "res://Objects") -> Item:
	var dir = DirAccess.open(root_path)
	if dir == null:
		push_error("❌ Cannot open directory: " + root_path)
		return null

	dir.list_dir_begin()
	while true:
		var file_name = dir.get_next()
		if file_name == "":
			break
		var full_path = root_path + "/" + file_name

		if dir.current_is_dir():
			if file_name.begins_with("."):
				continue  # skip .import, .godot, etc.
			var found = find_item_by_name_deep(target_name, full_path)
			if found:
				return found
		elif file_name.ends_with(".tscn"):
			var scene = load(full_path)
			if scene is PackedScene:
				var instance = scene.instantiate()
				if instance is Item and instance.item_name.to_lower() == target_name.to_lower():
					return instance
	return null


func InventoryStorageUpdate(addOrRemove, Item, quantity):
	if quantity == null or quantity == 0:
		quantity = 1
	pass#print("📢 InventoryStorageUpdate CALLED from:", self)

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

	elif typeof(Item) == TYPE_STRING:
		item_name = Item
		item_instance = find_item_by_name_deep(item_name)
		if item_instance == null:
			pass#print("❌ Could not find item scene for:", item_name)


	#print("🛠 Adding to Inventory: Name:", item_name, " | Object:", item_instance)
	for i in range(quantity):
		if addOrRemove == "Remove":
			for name in InventoryStorage.keys():
				#print("🧩 Inventory Keys:", InventoryStorage.keys())
				pass#print("🧩 Trying to remove:", Item)
				if name.to_lower() == Item.to_lower():
					InventoryStorage[name]["quantity"] -= 1
					pass#print("➖ Removed 1", name, "→ Remaining:", InventoryStorage[name]["quantity"])
					if InventoryStorage[name]["quantity"] <= 0:
						InventoryStorage.erase(name)
					break
		elif addOrRemove == "Add":
			pass#print(str(Item) + " Being added")
			if InventoryStorage.has(item_name) and item_instance.is_stackable:
				InventoryStorage[item_name].quantity += 1
			else:
				InventoryStorage[item_name] = {
					"item": item_instance,
					"quantity": 1,
				}
	if UI == null:
		UI = get_tree().get_current_scene().find_child("UI_HUD", true, false)

	if UI and item_instance and item_instance.icon:
		var notif_to_spawn = inv_notif.instantiate()
		notif_to_spawn.set_item(item_instance.icon, quantity)
		notif_to_spawn.custom_minimum_size = Vector2(64, 64)
		UI.add_child(notif_to_spawn)
		await get_tree().process_frame
		UI.queue_sort()
	else:
		pass#print("❌ UI_HUD still null at time of notification")
	



func get_item_amount(item_name: String) -> int:
	if InventoryStorage.has(item_name):
		return InventoryStorage[item_name]["quantity"]  # ✅ Get the stored quantity
	return 0  # ✅ Return 0 if the item isn't in inventory

func ensure_ui_ready() -> void:
	var tries = 10
	while tries > 0:
		UI = get_tree().get_root().find_child("UI_HUD", true, false)
		if UI:
			return
		await get_tree().process_frame
		tries -= 1
	#print("❌ UI_HUD not found after waiting.")

func craft_item(item_name: String):
	#print("Attempting Craft")
	if crafting_manager:
		crafting_manager.craft(item_name, self)
		FullfillmentManager.crafted.emit(item_name)
			
func _on_scene_changed(new_scene):
	pass#print("🎬 Scene changed to:", new_scene.name)

	for i in range(30):
		UI = new_scene.find_child("UI_HUD", true, false)
		if UI:
			#print("✅ UI_HUD found on attempt", i)
			break
		await get_tree().process_frame

	if UI == null:
		pass#print("❌ UI_HUD STILL NOT FOUND after waiting!")
		
func _process(delta):
	if UI == null:
		var current_scene = get_tree().get_current_scene()
		var found = current_scene.find_child("UI_HUD", true, false)
		if found:
			#print("✅ UI_HUD found via get_current_scene:", found)
			UI = found
		else:
			pass#print("❌ UI_HUD NOT FOUND in current_scene:", current_scene.name)



