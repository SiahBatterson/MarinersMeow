extends Node2D

var moving = true

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.connect("FishCaught",Callable(self,"FishTorial"))
	InventoryManager.msq_tracker += 1
	InventoryManager.boatEvent("Damage",70)
	if InventoryManager.msq_tracker == 1:
		DialogOrchestrator.start_dialog_set("MayorWhiskers", "quest_intro")

func FishTorial():
	DialogOrchestrator.start_dialog_set("MayorWhiskers", "fishingTutorial")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept") and moving:
		SignalBus.stopBoat.emit()
		moving = false
	elif Input.is_action_just_pressed("ui_accept") and !moving:
		SignalBus.startBoat.emit()
		moving = true
