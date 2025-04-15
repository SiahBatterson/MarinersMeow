extends Control

@export var profileIcon: Texture
@export var wood_to_repair = 2
@export var damaged_health: Texture
@export var regular_health: Texture

func _ready():
	pass
	
func ShopKeeperSet(profile):
	$Profile/profilePhoto.texture = profile
	

func shopkeeper_says(text):
	$Profile/TextureRect/RichTextLabel.text="[center]"+text

func check_materials():
	return InventoryManager.get_item_amount("Wood")>wood_to_repair

func _process(delta):
	$BoatScreen/TextureRect/TextureProgressBar.value = InventoryManager.boatIntegrity
	$CoinCount/RichTextLabel.text = str(InventoryManager.currentBalance)
	if InventoryManager.boatIntegrity < 50:
		$BoatScreen/TextureRect/TextureProgressBar.texture_progress = damaged_health
	else:
		$BoatScreen/TextureRect/TextureProgressBar.texture_progress = regular_health

func _on_repair_boat_mouse_entered():
	if check_materials():
		shopkeeper_says("Want to repair?")
	else:
		shopkeeper_says("Come back when you got some wood!")
	pass # Replace with function body.


func _on_repair_boat_mouse_exited():
	shopkeeper_says("Whatr you looking at?")


func _on_repair_boat_pressed():
	if check_materials():
		shopkeeper_says("I'll get right on that.")
		InventoryManager.boatEvent("Repair",10)
	else:
		shopkeeper_says("Seriously stop wasting my time.")
