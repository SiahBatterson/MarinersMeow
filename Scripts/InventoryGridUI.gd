extends GridContainer

var InventoryStorage
@onready var inventory_grid = $"."  # Reference to GridContainer
@onready var inventory_slot_scene = preload("res://Objects/InventorySlot.tscn")

func _ready():
	SignalBus.connect("InvVisible",Callable(self,"invvisible"))
	SignalBus.connect("debug_inventory",Callable(self,"debug_inv"))
	InventoryStorage = InventoryManager.InventoryStorage
	SignalBus.connect("InventoryUpdate", Callable(self, "InventoryStorageUpdate"))
	update_inventory_ui()  # Initial UI update

func debug_inv():
	print($".".get_children())

func invvisible():
	print("🧨 Toggling inventory visibility")
	$"../..".visible = !$"../..".visible

func InventoryStorageUpdate(add,item,quantity):
	InventoryStorage = InventoryManager.InventoryStorage
	#print(InventoryStorage)
	update_inventory_ui()

func update_inventory_ui():
	# Clear the grid first
	for child in inventory_grid.get_children():
		child.queue_free()

	# Add items to the grid
	for item_name in InventoryStorage.keys():
		var slot = inventory_slot_scene.instantiate()
		var item_data = InventoryStorage[item_name]
		var quantity = item_data.get("quantity", 0)
		var Item_Instance = item_data.get("item", null)

		if Item_Instance == null:
			print("Item instance is null for:", item_name)
			continue

		if not "icon" in Item_Instance:
			print("Item has no 'icon' property:", item_name)
			continue

		var texture = Item_Instance.icon
		if texture is CompressedTexture2D:
			var image = texture.get_image()
			var new_texture = ImageTexture.create_from_image(image)
			texture = new_texture  # Assign converted texture
		# Set slot button texture
		slot.texture_normal = texture  # Assuming `icon` is a texture in item
		slot.item =  Item_Instance
		var label = slot.get_node("QuantityLabel") if slot.has_node("QuantityLabel") else null
		if label:
			label.text = "x" + str(quantity)
		#print("Slot Contains: " + str(slot.item))

		inventory_grid.add_child(slot)
		#print($".".get_children())
