extends TextureRect
@export var timeout_time = 5
@export var replacement_text: String

func _ready():
	modulate = Color(1,1,1,0)
	if replacement_text != "":
		$RichTextLabel.text = replacement_text

func go():
	modulate.a = 0.0
	#$AudioStreamPlayer2D.play()

	# Tween in
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,1), 0.2)
	await tween.finished

	# Wait for 5 seconds
	await get_tree().create_timer(timeout_time).timeout

	# Tween out
	tween = create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,0), 0.2)
	await tween.finished

	queue_free()
	
func on_click():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.6).set_trans(Tween.TRANS_SINE)
	await tween.finished

	queue_free()


func _on_pressed():
	on_click()


func _on_visibility_changed():
	go()


func _on_open_crafting_button_visibility_changed():
	go()
