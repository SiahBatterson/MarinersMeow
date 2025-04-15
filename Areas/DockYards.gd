extends TextureButton
@export var timeout_time = 5

func _ready():
	modulate = Color(1,1,1,0)

func go():
	modulate.a = 0.0
	#$AudioStreamPlayer2D.play()

	# Tween in
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,1), 0.2)


func _on_visibility_changed():
	go()
