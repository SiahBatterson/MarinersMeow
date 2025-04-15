extends RichTextLabel  # or RichTextLabel

var blinking = false

func _ready():
	DialogOrchestrator.connect("broadcast_condition",Callable(self,"conditionNeeded"))
	start_blinking()

func conditionNeeded(condition,blink):
	$".".text = "[center]"+condition
	if blink:
		start_blinking()
	else:
		stop_blinking()

func start_blinking():
	blinking = true
	blink()

func stop_blinking():
	blinking = false

func blink():
	if not blinking:
		return

	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	tween.connect("finished", Callable(self, "blink"))
