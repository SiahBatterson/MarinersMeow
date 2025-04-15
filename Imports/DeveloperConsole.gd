extends LineEdit

@export var guppy: PackedScene
var packed_scene
# Called when the node enters the scene tree for the first time.
func _ready():
	packed_scene = preload("res://Gameplay Objects/UI_Elements/Upgrades/Pots/upgrade_crab_pots.tscn")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("coin"):
		Inventory.currency += 100
	pass


func _on_text_submitted(new_text):
	if new_text == "reroll":
		Signals.reroll.emit()
		print("submit")
	if new_text == "display":
		Signals.shopdisplay.emit()
	if new_text == "guppy":
		print(str($"../IslandShop/ShopBackground/GridContainer".get_child_count()))
		Signals.exiting_storm.emit()
	if new_text == "coin":
		Inventory.currency += 100
	if new_text == "LvUp":
		Signals.xp_gained.emit(100)
	if new_text == "fish":
		print("Fish Inventory: " + str(Inventory.fish))
		#print("Children of fish holder: " + str($"../IslandShop/ShopBackground/CenterContainer2/GridContainer".get_children()))
	if new_text == "pot":
		var unpacked = packed_scene.instantiate()
		Signals.upgrade_purchased.emit(unpacked,packed_scene)
		Signals.upgrade_inventory_updated.emit()
	if new_text == "lf":
		var legendary_fish_packed = preload("res://Gameplay Objects/Fish/Red Tail.tscn")
		var legendary_fish = legendary_fish_packed.instantiate()
		#legendary_fish.crabpot_fish_setup()
		legendary_fish.fish_rarity = "Legendary"
		legendary_fish.set_fish_rarity("Legendary")
		Signals.fish_caught.emit(legendary_fish)
		print(str(legendary_fish.fish_rarity))
		$"../IslandShop/ShopBackground/CenterContainer2/GridContainer".update_items()
	if new_text == "serial":
		Inventory.on_save_serialize()
