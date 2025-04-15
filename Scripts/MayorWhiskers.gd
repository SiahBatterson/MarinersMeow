extends Control

@export var Dialog = []
var currentDiaIndex: int = 0
@export var starterMaterials = []

# Called when the node enters the scene tree for the first time.
func _ready():
	$Dialog/ChatWindow/RichTextLabel.trigger_speech("Hello There!")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("e"):
		if currentDiaIndex < Dialog.size()-1:
			currentDiaIndex += 1
			$Dialog/ChatWindow/RichTextLabel.trigger_speech(Dialog[currentDiaIndex])
		else:
			$Dialog/ChatWindow/RichTextLabel.trigger_speech("None")
			$"../Notification".visible = true
			SignalBus.InventoryUpdate.emit("Add",starterMaterials[0])
			SignalBus.InventoryUpdate.emit("Add",starterMaterials[1])
	pass
