extends Control

@onready var crafting_manager = $UI
@onready var inventory_manager = InventoryManager
@onready var craftingButton = preload("res://Objects/crafting_button.tscn")

func _ready():
	#print("Lodaed Crafting UI Correctly")
	update_crafting_list()
	SignalBus.connect("openCrafting", Callable(self, "openUI"))

func openUI():
	#print("Opening Crafting UI")
	$".".visible = !$".".visible

func update_crafting_list():
	var craft_list = $UI/VBoxContainer

	for item_name in crafting_manager.recipes.keys():
		var button = craftingButton.instantiate()
		if button == null:
			#print("❌ craftingButton.instantiate() returned null")
			continue

		var texture_button = button.get_node("TextureButton")
		if texture_button == null:
			#print("❌ 'TextureButton' node not found in crafting_button scene")
			continue
		var item_path = "res://Objects/Craftable/" + item_name + ".tscn"
		var icon_texture: Texture2D = null

		if ResourceLoader.exists(item_path):
			var item_scene = load(item_path)
			var item_instance = item_scene.instantiate()

			if "icon" in item_instance:
				icon_texture = item_instance.icon
				
		texture_button.texture_normal = icon_texture



		texture_button.tooltipInfo = item_name
		var crafting_ingredients = crafting_manager.get_recipe(item_name)
		texture_button.ingredients = crafting_ingredients
		#print(texture_button.ingredients)

		# Connect button interactions
		texture_button.connect("pressed", Callable(self, "on_craft_pressed").bind(item_name))
		texture_button.connect("mouse_entered", Callable(self, "_on_mouse_entered").bind(item_name))
		texture_button.connect("mouse_exited", Callable(self, "_on_mouse_exited"))

		craft_list.add_child(button)

func on_craft_pressed(item_name):
	#print("InventoryManager")
	inventory_manager.craft_item(item_name)
	

func _on_mouse_entered(item_name):
	if not crafting_manager.recipes.has(item_name):
		print(":x: No recipe found for:", item_name)
		return

	var ingredient_data = {}
	var recipe = crafting_manager.recipes[item_name]["ingredients"]
	#var crafted_item_name = null
	for ingredient_name in recipe.keys():
		var ingredient_amount = recipe[ingredient_name]
		var ingredient_path = "res://Objects/CraftingMaterials/" + ingredient_name + ".tscn"
		var ingredient_scene = load(ingredient_path)
		#crafted_item_name = ingredient_scene.item_name
		#print("Loading:", ingredient_path)

		if ingredient_scene:
			var ingredient_instance = ingredient_scene.instantiate()
			var ingredient_icon = ingredient_instance.icon
			#print("Ingredient created with icon: " + str(ingredient_icon))

			ingredient_data[ingredient_name] = {
				"icon": ingredient_icon,
				"amount": ingredient_amount
			}

	# Debugging output
	#print("Emitting ingredient data with type:", str(typeof(ingredient_data)))
	var safe_ingredient_data = {}  # :white_check_mark: New dictionary

	for key in ingredient_data.keys():
		safe_ingredient_data[key] = ingredient_data[key]  # :white_check_mark: Manually copy to ensure it's a Dictionary

	
	SignalBus.craftingTooltip.emit(safe_ingredient_data, item_name)

func _on_mouse_exited():
	SignalBus.hideCraftingTooltip.emit()


func _on_area_2d_area_entered(area):
	SignalBus.interactableNearby.emit(true)
	SignalBus.craftingAllowed.emit(true)


func _on_area_2d_area_exited(area):
	SignalBus.interactableNearby.emit(false)
	SignalBus.craftingAllowed.emit(false)
	$UI.hide()
