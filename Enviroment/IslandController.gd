extends Node2D

@export var itemTest = []
@export var storm: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	DialogManager.load()
	DialogManager.save()
	GameManager.hideUIonScene()
	print("Island Loaded Correctly")
	print("Scenes in island:")
	print("---------------------------------")
	for child in get_children():
		print(child.name)
	print("UI Scenes:")
	for kid in $UI.get_children():
		print(kid.name)
	print("---------------------------------")
	if InventoryManager.msq_tracker == 0:
		DialogOrchestrator.start_dialog_set("MayorWhiskers", "intro")
	if InventoryManager.msq_tracker == 1:
		DialogOrchestrator.start_dialog_set("MayorWhiskers", "DockTutorial")
		GameManager.main_tutorial_done = true
		InventoryManager.msq_tracker = 2
	SignalBus.connect("InventoryUpdate",Callable(self,"Check"))
	SignalBus.connect("CastOff",Callable(self,"NotifCast"))
	if GameManager.main_tutorial_done:
		$UI/OpenCraftingButton.show()
		$UI/CastOff.show()
		$UI/InventoryButton.show()
		$UI/OpenCraftingButton/Notification.queue_free()
	pass # Replace with function body.

func NotifCast():
	$Notification2.show()

func Check(add,check):
	if check is PackedScene:
		var checked = check.instantiate()
		if checked.item_name == "Basic Rod":
			pass#SignalBus.CastOff.emit()
	else:
		var name = check
		if name == "Basic Rod":
			pass#	print("HEFEWGEF")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("e"):
		SignalBus.InventoryUpdate.emit ("Add", itemTest[0], 2)
		SignalBus.InventoryUpdate.emit("Add", itemTest[1], 1)
		SignalBus.debug_inventory.emit()
	if Input.is_action_just_pressed("debug_button"):
		$Dock/DockYards.show()
	pass


func _on_dock_yards_pressed():
	$Dock/DockCat.visible = !$Dock/DockCat.visible
	DialogOrchestrator.start_dialog_set("DockCat","dockcat_introduction")
