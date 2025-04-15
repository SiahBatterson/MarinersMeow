extends TextureRect

var tween: Tween = null

var fog_offset := Vector2.ZERO
var image_offset := Vector2.ZERO

# Store target speeds here
var current_speed := Vector2(0.25, 0.00)
var current_image_speed := Vector2(0.4, 0.00)

func _process(delta):
	fog_offset += current_speed * delta
	image_offset += current_image_speed * delta
	material.set_shader_parameter("fog_offset", fog_offset)
	material.set_shader_parameter("image_offset", image_offset)

func _ready():
	SignalBus.connect("stopBoat", Callable(self, "StopBoat"))
	SignalBus.connect("startBoat", Callable(self, "StartBoat"))

func StopBoat():
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "current_speed", Vector2.ZERO, 1.0)
	tween.parallel().tween_property(self, "current_image_speed", Vector2.ZERO, 1.0)

func StartBoat():
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "current_speed", Vector2(0.25, 0.0), 1.0)
	tween.parallel().tween_property(self, "current_image_speed", Vector2(0.4, 0.0), 1.0)
