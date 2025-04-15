extends TextureButton

var tooltipInfo: String
var ingredients: Dictionary
var item_name: String
@onready var icon: Texture = $".".texture_normal
@onready var inventory_manager = InventoryManager


const HOVER_COLOR = Color(1,1,1,0.9)
const NORMAL_COLOR = Color(1,1,1,1)
const TWEEN_DURATION = 0.15

var tween

func has_enough_ingredients() -> bool:
	for ingredient in ingredients.keys():
		var needed = ingredients[ingredient]
		var have = inventory_manager.get_item_amount(ingredient)

		if have < needed:
			return false
	return true

func _on_pressed():
	print("I CRAFTED")

func _ready():
	$"..".set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	$"..".size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	$"..".size_flags_vertical = Control.SIZE_SHRINK_CENTER


func _on_mouse_entered():
	var item_id = tooltipInfo
	var item_name = item_id.replace("_", " ").capitalize()
	SignalBus.craftingTooltip.emit(ingredients, icon, item_id)

	# Animate scale up
	_tween_to_scale(HOVER_COLOR)

func _on_mouse_exited():
	SignalBus.hideCraftingTooltip.emit()

	# Animate scale down
	_tween_to_scale(NORMAL_COLOR)

func _tween_to_scale(target_color: Color):
	if tween and tween.is_running():
		tween.kill()

	tween = create_tween()
	tween.tween_property($"..", "modulate", target_color, TWEEN_DURATION)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

