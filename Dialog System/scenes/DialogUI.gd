extends CanvasGroup

func _ready():
	$Timer.wait_time = talking_speed
	SignalBus.connect("DialogStatus", Callable(self, "DiaStatus"))
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	if icon_override:
		$Portrait_Background/Portrait.texture = icon_override_icon

func DiaStatus(status):
	if status == "Active":
		show()
	else:
		hide()
		$AudioStreamPlayer2D.stream = null
		$AudioStreamPlayer2D.stop()

func display_line(speaker: String, text: String, portrait: Texture2D = null):
	$NameLabel.text = speaker
	trigger_speech(text)

	if portrait and not icon_override:
		$Portrait_Background/Portrait.texture = portrait
	elif not portrait and not icon_override:
		$Portrait_Background/Portrait.texture = null

# === TYPEWRITER LOGIC ===

var shown_text
var current_position = 0
var visible_char
var textShow
@export var icon_override: bool = false
@export var icon_override_icon: AtlasTexture
@export var talking_speed: float = 0.08
@onready var textBox = $TextLabel
@onready var timer = $Timer

func trigger_speech(speech):
	if speech == "None":
		hide()

	if speech.length() >= 35:
		textBox.add_theme_font_size_override("normal_font_size", 20)
	elif speech.length() >= 25:
		textBox.add_theme_font_size_override("normal_font_size", 30)
	elif speech.length() >= 15:
		textBox.add_theme_font_size_override("normal_font_size", 27)
	elif speech.length() <= 10:
		textBox.add_theme_font_size_override("normal_font_size", 50)

	shown_text = ""
	visible_char = 0
	current_position = 8
	textShow = speech
	textBox.text = ""
	timer.start()

func _on_timer_timeout():
	var rnd = RandomNumberGenerator.new()
	rnd.randomize()
	var rndnum = rnd.randi_range(1, 3)
	var pitch = 0.33 if rndnum == 1 else (0.32 if rndnum == 2 else 0.31)

	var end_index = min(visible_char, textShow.length())
	textBox.text = textShow.substr(0, end_index)

	if visible_char >= textShow.length():
		$AudioStreamPlayer2D.stop()
		timer.stop()
	else:
		visible_char += 1
		$AudioStreamPlayer2D.pitch_scale = pitch
		$AudioStreamPlayer2D.play()
