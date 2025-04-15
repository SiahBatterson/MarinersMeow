extends TextureButton

@export var level_needed: int = 1
var is_not_level

# Called when the node enters the scene tree for the first time.
var original_scale: Vector2  # define as a Vector2, not a float

func _ready():
	await get_tree().process_frame  # Wait one frame so layout completes
	original_scale = Vector2(.7,.7)
	print("✅ Final assigned scale:", original_scale)
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_not_level:
		$TextureRect/RichTextLabel.modulate = Color(0.5, 0.5, 0.5)  # medium gray
		$".".modulate = Color(1,1,1,0.8)
	pass

func _on_mouse_entered():
	scale = original_scale * 1.1  # Slight grow effect
	modulate = Color(1, 1, 1, 1)  # Optional: brighten

func _on_mouse_exited():
	scale = original_scale
	modulate = Color(0.9, 0.9, 0.9, 1)  # Optional: dim a bit

