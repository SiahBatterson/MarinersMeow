extends Node2D

@onready var showME = false

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Inventory Exists")
	SignalBus.connect("InvVisible",Callable(self,"showSelf"))

func _process(delta):
	if showME:
		show()
	else:
		hide()

func showSelf():
	showME = !showME
	modulate = Color(1, 1, 1, 1)
	print("Before toggle:", visible)
	self.visible = !self.visible
	print("After toggle:", visible)

