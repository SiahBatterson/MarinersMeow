extends Control

@onready var text_self = $RichTextLabel
@export var override_text: String
@export var override: bool
var notif_icon: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready():
	text_self = $RichTextLabel
		
func exit():
	var tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	$Timer.start()
	var target_modulate = modulate
	target_modulate.a = 0.0  # Fully transparent
	tween2.tween_property(self, "modulate", target_modulate, 1.5)
	#print("ICON RECEIVED: " + str(notif_icon))
	var final_position = position + Vector2(0, -200)  # The current position is where you want the object to end up
	#var start_position = final_position + Vector2(0, 300)  # Start position is 900 units to the left

	# Set the object to the start position
	#position = start_position

	# Tween from the start position back to the final position
	tween.tween_property($".", "position", final_position, 1.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if override:
		text_self = "[center]" + override_text


func _on_timer_timeout():
	queue_free()
	pass # Replace with function body.


func _on_exit_button_pressed():
	exit()
