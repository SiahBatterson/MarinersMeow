extends Control

var fish
var amount_of_fish
var current_fish
var hotspot

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.connect("hotspotReached", Callable(self,"LinkHotspot"))
	pass # Replace with function body.

func LinkHotspot(hotspot_):
	hotspot = hotspot_
	amount_of_fish = hotspot.density
	fish = hotspot.fish
	draw_fish()

func draw_fish():
	if (amount_of_fish > 0):
		amount_of_fish-=1
		print("Amount of Fish: " + str(amount_of_fish))
		current_fish = fish.pick_random()
		print("Fish Drawn: " + str(current_fish))
		$Button.fish = current_fish
		$Button.fishing = true
		$Button.number = 0
		$Button.notCaught = true
		$Button.tick_timer = 0
		$TextureProgressBar.value = 0
		var icon_add = current_fish.instantiate()
		$FishBackground/FishIcon.texture = icon_add.icon 
		$Button.show()
	else:
		$Button.hide()
		var duplicate = load("res://Imports/notification_new.tscn")
		var notif = duplicate.instantiate()
		hotspot.tween_opacity_with_callback(hotspot,0)
		notif.override_text = "No more fish left!"  # Deep copy of the existing node
		#add_child(notif)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
