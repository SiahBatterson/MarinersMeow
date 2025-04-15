extends Node2D

@export var speed: int = 200  # Speed of the scrolling
var original_speed
var slow_speed
@export var reset_modifier: float = 2400  # Amount to shift further left before reset
@export var start_x_modifier: float = -1400  # Amount to shift textures to the left at the start
@export var hotspotCollections: Array 
var spawn_timer: float = 0.0
var next_spawn_time: float = 0.0
var texture_width: float  # Width of each sprite or texture
var screen_width: float  # Width of the visible screen
var moving: bool = true  # To control the movement state
@export var upperSpawnTime: int = 75

func Stop():
	if not moving:
		return
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "speed", slow_speed, 1.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# When tween is finished, stop motion fully
	tween.tween_callback(Callable(self, "_on_stop_complete"))

func _on_stop_complete():
	pass
	
func Start():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "speed", original_speed, 1.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# When tween is finished, stop motion fully
	tween.tween_callback(Callable(self, "_on_start_complete"))

func _on_start_complete():
	pass

func _ready():
	original_speed = speed
	slow_speed = speed/7
	SignalBus.connect("stopBoat",Callable(self,"Stop"))
	SignalBus.connect("startBoat",Callable(self,"Start"))
	# Get the width of the first Sprite2D/TextureRect and the screen width
	for child in get_children():
		if child is Sprite2D or child is TextureRect:
			texture_width = child.texture.get_size().x  # Assuming all textures are the same size
			break  # Only need to check one child for texture size

	screen_width = get_viewport().size.x  # Get the screen width

	# Position the first texture at the far left (x = 0) minus the start_x_modifier, and the others next to each other
	for i in range(get_child_count()):
		var child = get_child(i)
		if child is Sprite2D or child is TextureRect:
			child.position.x = (i * texture_width) + start_x_modifier  # Adjust the starting position

func turn_moving_off():
	#moving = false
	var tween = get_tree().create_tween()  # Create a tween
	tween.tween_property(self, "speed", slow_speed, 2)  # Lerp speed to 0 over 1 second

func _process(delta):
	if moving:
		# Move all textures every frame
		for child in get_children():
			if child is Sprite2D or child is TextureRect:
				child.position.x -= speed * delta
				#print(str(child.position))

				if child.position.x <= -texture_width - reset_modifier:
					var max_x = get_rightmost_sprite_position()
					child.queue_free()

		# Handle spawn timer
		spawn_timer += delta
		if spawn_timer >= next_spawn_time:
			_spawn_random_scene()
			_set_next_spawn_time()
			spawn_timer = 0.0

# Helper function to get the x position of the rightmost Sprite2D/TextureRect
func get_rightmost_sprite_position() -> float:
	var max_x = -INF
	for child in get_children():
		if child is Sprite2D or child is TextureRect:
			max_x = max(max_x, child.position.x)
	return max_x

func _spawn_random_scene():
	var rnd = RandomNumberGenerator.new()
	rnd.randomize()
	var rndnum = rnd.randi_range(1,3)
	if hotspotCollections.is_empty():
		return

	var scene = hotspotCollections.pick_random()
	var instance = scene.instantiate()

	# Optional: Ensure it's a type we can move
	if not (instance is Sprite2D or instance is TextureRect):
		push_error("Spawned scene is not Sprite2D or TextureRect")
		return

	# Place the new instance to the right of the rightmost existing one
	var max_x = get_rightmost_sprite_position()
	instance.position.x = position.x
	instance.density = rndnum
	add_child(instance)

func _set_next_spawn_time():
	next_spawn_time = randf_range(5.0, upperSpawnTime)

func _on_boat_speed_timeout():
	speed *= 1.05
