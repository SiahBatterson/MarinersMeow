extends Control

var zoom_speed = 0.05
var max_zoom = 2.0
var min_zoom = 0.3
var pan_speed = 0.8
var dragging = false
var last_mouse_position = Vector2()
var current_zoom = 1.0

func _ready():
	set_mouse_filter(Control.MOUSE_FILTER_PASS)

# Handle panning and zooming
func _process(delta):
	handle_panning()
	handle_zoom()

# Pan with left-click and drag
func handle_panning():
	if Input.is_action_pressed("ui_left_click"):
		if not dragging:
			dragging = true
			last_mouse_position = get_global_mouse_position()
		else:
			var mouse_delta = get_global_mouse_position() - last_mouse_position
			# Move the content and apply the delta
			position.x += mouse_delta.x * pan_speed
			position.y += mouse_delta.y * pan_speed
			last_mouse_position = get_global_mouse_position()
	else:
		dragging = false

# Handle zoom in and out
func handle_zoom():
	if Input.is_action_just_pressed("ui_scroll_up"):
		current_zoom = max(current_zoom - zoom_speed, min_zoom)
	elif Input.is_action_just_pressed("ui_scroll_down"):
		current_zoom = min(current_zoom + zoom_speed, max_zoom)

	# Scale the content based on the zoom factor
	scale = Vector2(current_zoom, current_zoom)

	# Ensure the position stays within bounds when zooming
	clamp_position()

# Ensure the skill tree stays within bounds after panning and zooming
func clamp_position():
	pass#var min_pos = Vector2(0, 0)  # Upper-left limit (adjust as necessary)
	#var max_pos = Vector2(size.x * (current_zoom - 1), size.y * (current_zoom - 1))  # Lower-right limit (adjust as necessary)

	#position.x = clamp(position.x, -max_pos.x, min_pos.x)
	#position.y = clamp(position.y, -max_pos.y, min_pos.y)
