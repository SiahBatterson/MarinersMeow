extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.connect("inventoryTooltip",Callable(self,"tooltip"))
	pass # Replace with function body.

func tooltip(tooltip,type):
	if type == "money":
		$".".text = (str(tooltip) + " coins")
	if type == "clear":
		$".".text = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
