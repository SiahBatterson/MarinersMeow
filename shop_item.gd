extends Control

var itemName
var texture
var price

# Called when the node enters the scene tree for the first time.
func _ready():
	modulate = Color(1,1,1,0.8)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if texture != null:
		$TextureButton.texture_normal = texture
	pass

func has_enough_currency():
	return InventoryManager.currentBalance >= price


func _on_texture_button_pressed():
	var shop_ui = get_parent().get_parent()
	if has_enough_currency():
		SignalBus.InventoryUpdate.emit("Add",itemName,1)
	else:
		shop_ui.shopkeeper_says("What you think im a chartiy?")

func _on_texture_button_mouse_entered():
	var shop_ui = get_parent().get_parent()  # or however many levels up
	modulate = Color(1,1,1,1)
	SignalBus.inventoryTooltip.emit(price,"spendmoney")
	if shop_ui.has_signal("shopkeeperPricingCheck"):
		shop_ui.emit_signal("shopkeeperPricingCheck", InventoryManager.currentBalance >= price)



func _on_texture_button_mouse_exited():
	modulate = Color(1,1,1,0.8)
	SignalBus.inventoryTooltip.emit(price,"clear")
	var shop_ui = get_parent().get_parent()
	shop_ui.shopkeeper_says("")


