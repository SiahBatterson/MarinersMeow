extends Camera2D

# Variables to handle panning and zooming
var zoom_speed = 0.1
var max_zoom = 3.0
var min_zoom = 0.5
var pan_speed = 5.0
var dragging = false
var last_mouse_position = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Handle zoom and panning
func _process(delta):
	handle_zoom()
	handle_panning()

# Function to zoom in and out
func handle_zoom():
	# Detect mouse wheel scroll for zooming
	if Input.is_action_just_pressed("ui_scroll_up"):
		zoom = Vector2(zoom.x - zoom_speed, zoom.y - zoom_speed)
	elif Input.is_action_just_pressed("ui_scroll_down"):
		zoom = Vector2(zoom.x + zoom_speed, zoom.y + zoom_speed)

	# Clamp the zoom value to prevent over-zooming
	zoom.x = clamp(zoom.x, min_zoom, max_zoom)
	zoom.y = clamp(zoom.y, min_zoom, max_zoom)

# Function to handle panning
func handle_panning():
	# Check if the middle mouse button is pressed to start panning
	if Input.is_action_pressed("mouse_middle"):
		if not dragging:
			dragging = true
			last_mouse_position = get_global_mouse_position()
		else:
			# Calculate mouse delta and move the camera by that amount
			var mouse_delta = get_global_mouse_position() - last_mouse_position
			position -= mouse_delta * pan_speed
			last_mouse_position = get_global_mouse_position()
	else:
		dragging = false
