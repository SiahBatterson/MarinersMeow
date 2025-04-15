extends RichTextLabel

@onready var rich_text_label = $"."

# Called when the node enters the scene tree for the first time.
func _ready():
	print($".")  # Debugging to verify node type
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rich_text_label.text = "[center]" + str(SignalBus.player_stamina) + " Stamina"
