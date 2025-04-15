extends RichTextLabel

var shown_text
var current_position = 0
var visible_char
var textShow
@export var icon_override: bool = false
@export var icon_override_icon: AtlasTexture
@export var textBox: RichTextLabel
@export var timer: Timer
#@onready var current_fontSize = $PortraitBox2/RichTextLabel.get_theme_font_size_override("normal_font_size")

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.connect("timeout",Callable(self,"_on_timer_timeout"))
	if icon_override:
		$Sprite2D.texture = icon_override_icon
	pass # Replace with function body.

func trigger_speech(speech):
	if speech == "None":
		$"../..".hide()
	if speech.length() >= 20:
		textBox.add_theme_font_size_override("normal_font_size",30)
	if speech.length() >= 30:
		textBox.add_theme_font_size_override("normal_font_size",25)
	if speech.length() >= 35:
		textBox.add_theme_font_size_override("normal_font_size",20)
	if speech.length() <= 14:
		textBox.add_theme_font_size_override("normal_font_size",40)
	shown_text = ""
	visible_char = 0
	current_position = 8
	textShow = speech
	#print("Show: " + textShow)
	var length = textShow.length()

	timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass#print(textBox.text)


func _on_timer_timeout():
	var rnd = RandomNumberGenerator.new()
	rnd.randomize()
	var rndnum = rnd.randi_range(1,3)
	var pitch
	var length = text.length()
	if rndnum == 1:
		pitch = .33
	if rndnum == 2:
		pitch = .32
	if rndnum == 3:
		pitch = .31
	var end_index = min(visible_char, textShow.length())
	textBox.text = textShow.substr(0, end_index)
	#print(str(str(visible_char)))
	if visible_char >= textShow.length():
		$"../../AudioStreamPlayer2D".stop()
		timer.stop()
		textBox.text = textBox.text
	else:
		visible_char += 1
		$"../../AudioStreamPlayer2D".pitch_scale = pitch
		$"../../AudioStreamPlayer2D".play()

