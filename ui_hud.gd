extends Control


func _ready():
	SignalBus.emit_signal("UIReady", self)
	
func _process(delta):
	if Input.is_action_just_pressed("check_child"):
		print("UI_HUD has: " + str(get_child_count()) + " children")
		print("UI_HUD Children:")
		for i in self.get_children():
			print("IN UI:" + str(i))
			for x in i.get_children():
				print("IN " + str(i) + ": " + str(x))
