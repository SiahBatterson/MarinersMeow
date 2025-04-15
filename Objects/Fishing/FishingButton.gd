extends TextureButton

@export var difficulty: float = 3
@export var number: float = 0
@onready var progress_bar = $"../TextureProgressBar"  # Adjust path if needed
var fishing = true
var fish = null
var notCaught = true

var tick_timer := 0.0
const TICK_INTERVAL := 0.5

func _ready():
	progress_bar.max_value = difficulty
	progress_bar.value = number
	self.pressed.connect(_on_pressed)

func startFishing():
	fishing = true
	notCaught = true

func _process(delta):
	if fishing:
		if number >= difficulty:
			notCaught = false
			fishing = false
			SignalBus.InventoryUpdate.emit("Add",fish,1)
			SignalBus.FishCaught.emit()
			hide()
			$"..".draw_fish()
		if notCaught:
			tick_timer += delta/2
		if tick_timer >= TICK_INTERVAL:
			number -= 1
			tick_timer = 0.0
			number = clamp(number, 0, difficulty)
			progress_bar.value = number
		

func _on_pressed():
	$Sound.play()
	var gain = max(1, 6 - difficulty)  # Easy = 5 gain, Hard = 1 gain
	number += gain
	number = clamp(number, 0, difficulty)

	progress_bar.value = number

	var tween = create_tween()
	var highlight_color = Color(1.0, 0.4, 0.4)  # Light red
	var normal_color = Color(1.0, 1, 1)     # Full red
	var tweenObject = $Button
	tween.tween_property(tweenObject, "self_modulate", highlight_color, 0.08)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(tweenObject, "self_modulate", normal_color, 0.08)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

