extends Control

@export var shopkeeperName: String
@export var shopkeeper_stock: Array[KeyValuePair]
var item_storage
@export var item_slot_scene: PackedScene
@onready var item_grid =  $GridContainer
signal shopkeeperPricingCheck(check)

@export var has_sell_window = false
@onready var sell_window = $"Sell Window/TextureRect2/ScrollContainer/SellGrid"

var my_dict: Dictionary = {}

func _ready():
	connect("shopkeeperPricingCheck",Callable(self,"priceCheck"))
	var temp_stock:= {}
	for entry in shopkeeper_stock:
		temp_stock[entry.key] = entry.value
	item_storage = temp_stock
	update_shop_ui()
	print(item_storage)
	print($GridContainer.get_children())

func priceCheck(check):
	print("PRICE CHECKED")
	if check:
		shopkeeper_says("Interested in that item?")
	else:
		shopkeeper_says("Come back when you got something to barter with!")

func ShopKeeperSet(profile):
	$Profile/profilePhoto.texture = profile
	

func shopkeeper_says(text):
	$Profile/TextureRect/RichTextLabel.text=text

func buildItemStorage():
	
	pass

func update_shop_ui():
	# Clear the grid first
	if has_sell_window:
		$"Sell Window".show()
		sell_window.refresh_sell_items()
	for child in item_grid.get_children():
		child.queue_free()

	# Add items to the grid
	for item_name in item_storage:
		var slot = item_slot_scene.instantiate()
		var item = InventoryManager.find_item_by_name_deep(item_name)
		var texture = item.icon
		if texture is CompressedTexture2D:
			var image = texture.get_image()
			var new_texture = ImageTexture.create_from_image(image)
			texture = new_texture  # Assign converted texture
		# Set slot button texture
		slot.texture = texture  # Assuming `icon` is a texture in item
		slot.itemName = item_name
		slot.price = item_storage[item_name]
		#slot.item =  item.instantiate()

		item_grid.add_child(slot)
		#print($".".get_children())
