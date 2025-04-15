extends TextureButton

var item = {}
var total_item_value;
var quantity

func _on_mouse_entered():
	modulate = Color(1,1,1,1)
	SignalBus.inventoryTooltip.emit(total_item_value,"money")
	
func _process(delta):
	var stringNum = $QuantityLabel.text
	var number = int(stringNum.replace("x", "").strip_edges())
	total_item_value = item.value*number
	if number > 9:
		$QuantityLabel.add_theme_font_size_override("normal_font_size",35)

func _ready():
	modulate = Color(1,1,1,0.9)

func _on_mouse_exited():
	SignalBus.inventoryTooltip.emit(total_item_value,"clear")
	modulate = Color(1,1,1,0.9)
