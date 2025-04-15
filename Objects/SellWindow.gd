extends GridContainer

@export var inventory_slot_scene: PackedScene
@onready var sell_grid: GridContainer = $"."

func _ready():
	SignalBus.connect("inventoryTooltip",Callable(self,"PriceUpdate"))
	refresh_sell_items()

func PriceUpdate(price_amount,type):
	if type=="spendmoney":
		$"../../../../Sells For/RichTextLabel".text = "[center]-"+str(price_amount)
	if type=="clear":
		$"../../../../Sells For/RichTextLabel".text = "[center]0"

func refresh_sell_items():
	$"../../../../Has/RichTextLabel".text = "[center]" + str(InventoryManager.currentBalance)
	# Clear existing slots
	for child in sell_grid.get_children():
		child.queue_free()

	# Add fish items from inventory
	for item_name in InventoryManager.InventoryStorage.keys():
		var item_data = InventoryManager.InventoryStorage[item_name]
		var item_instance = item_data.get("item")
		var quantity = item_data.get("quantity", 0)

		if item_instance == null or not "type" in item_instance or item_instance.type != "fish":
			continue

		var slot = inventory_slot_scene.instantiate()
		slot.texture_normal = item_instance.icon
		slot.item = item_instance
		slot.modulate = Color(1,1,1,0.9)

		var label = slot.get_node("QuantityLabel") if slot.has_node("QuantityLabel") else null
		if label:
			label.text = "x" + str(quantity)

		slot.connect("pressed", Callable(self, "_on_sell_pressed").bind(item_instance.item_name))
		slot.connect("mouse_entered", Callable(self, "_on_mouse_entered_slot").bind(item_instance))
		slot.connect("mouse_exited", Callable(self, "_on_mouse_exited_slot").bind(item_instance))
		sell_grid.add_child(slot)

func _on_sell_pressed(item_name: String):
	var quantity = InventoryManager.get_item_amount(item_name)
	if quantity <= 0:
		return

	var price = 1
	if InventoryManager.InventoryStorage.has(item_name):
		price = InventoryManager.InventoryStorage[item_name].item.sell_price if "sell_price" in InventoryManager.InventoryStorage[item_name].item else 1

	InventoryManager.InventoryStorageUpdate("Remove", item_name, 1)
	InventoryManager.currenyManager("add", price)
	$"../../../../Has/RichTextLabel".text = "[center]" + str(InventoryManager.currentBalance)
	refresh_sell_items()
	
func _on_mouse_entered_slot(item_instance):
	var price = 1
	item_instance.modulate = Color(1,1,1,1)
	if "value" in item_instance:
		price = item_instance.value

	var label = $"../../../../Sells For/RichTextLabel"
	if label and label is RichTextLabel:
		label.text = "[center]+" + str(price)

func _on_mouse_exited_slot(item_instance):
	var label = $"../../../../Sells For/RichTextLabel"
	item_instance.modulate = Color(1,1,1,0.9)
	if label and label is RichTextLabel:
		label.text = ""
