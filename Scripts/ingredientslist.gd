extends TextureRect	

@onready var ingredient_container = $Ingredients
@export var ingredient_slot_scene: PackedScene
@onready var inventory_manager = InventoryManager

func _ready():
	print("Info Panel Ready")
	SignalBus.connect("craftingTooltip", Callable(self, "show_tooltip"))
	SignalBus.connect("hideCraftingTooltip", Callable(self, "hide_tooltip"))
	hide()

func show_tooltip(ingredients: Dictionary, item_name: String):
	$Name.text = "[center]" + item_name.replace("_", " ").capitalize()
	# Debugging output to check received data
	print("Ingredients recieved for recipe: " + str(ingredients))
	print("Just got ingredients with type of: " + str(typeof(ingredients)))
	#$Name.text = "[center]" + item_name

	# Clear old slots
	for child in ingredient_container.get_children():
		child.queue_free()

	# Ensure ingredients are being processed
	if ingredients.size() == 0:
		return

	# Generate ingredient slots dynamically
	for ingredient in ingredients.keys():  # Loop through ingredient names
		var ingredient_data = ingredients.get(ingredient, null)  # ✅ Get the dictionary per ingredient
		var amount = ingredient_data["amount"]  # ✅ Directly access "amount"
		var icon_texture = ingredient_data["icon"]  # ✅ Directly access "icon"
		print("Icon: " + str(icon_texture))

		var slot = ingredient_slot_scene.instantiate()
		if not slot:
			continue
			
		  # ✅ Check if player has enough of this ingredient
		var amount_needed = ingredient_data["amount"]
		var amount_in_inventory = inventory_manager.get_item_amount(ingredient)  
		var has_enough = amount_in_inventory >= amount_needed
		

		
		print("Player " + str(has_enough) + " " + str(ingredient))

		var icon_node = slot.get_node("Icon") if slot.has_node("Icon") else null
		var amount_label = slot.get_node("Amount") if slot.has_node("Amount") else null
		
		if has_enough:
			icon_node.modulate = Color(1, 1, 1, 1)  # normal
		else:
			icon_node.modulate = Color(1, 0.3, 0.3, 1)  # red tint

		if not icon_node or not amount_label:
			continue

		icon_node.texture = icon_texture  # ✅ Set the icon
		amount_label.text = "x" + str(amount)  # ✅ Display the correct amount

		ingredient_container.add_child(slot)
		print("Amount of children in ingredients list: " + str(ingredient_container.get_child_count()))

	show()

func hide_tooltip():
	hide()
