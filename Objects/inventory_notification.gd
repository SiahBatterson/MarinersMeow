extends TextureButton

var offscreen_position
var original_position

func set_item(item_texture, quantity):
	await ready
	#print("Setting Notif Icon")
	$Item_Texture.texture = item_texture
	$Item_Texture.expand = true
	$Amount.text = "X" + str(quantity)

	original_position = position
	offscreen_position = original_position - Vector2(200, 0)

	position = offscreen_position
	modulate.a = 0.0
	$AudioStreamPlayer2D.play()

	# Tween in
	var tween = create_tween()
	tween.tween_property(self, "position", original_position, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)
	await tween.finished

	# Wait for 5 seconds
	await get_tree().create_timer(5.0).timeout

	# Tween out
	tween = create_tween()
	tween.tween_property(self, "position", offscreen_position, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate:a", 0.0, 0.6).set_trans(Tween.TRANS_SINE)
	await tween.finished

	queue_free()
	
func on_click():
	var tween = create_tween()
	tween.tween_property(self, "position", offscreen_position, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate:a", 0.0, 0.6).set_trans(Tween.TRANS_SINE)
	await tween.finished

	queue_free()


func _on_pressed():
	on_click()
