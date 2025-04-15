extends Node

@onready var QuestLog = preload("res://quest_log.tscn") 
var questlog_shown = false
var QuestLogClone
var main_tutorial_done = false

func hideUIonScene():
	QuestLogClone.hide()
	questlog_shown = false
# Called when the node enters the scene tree for the first time.
func _ready():
	QuestLogClone = QuestLog.instantiate()

func fade_in_node(target: CanvasItem, duration := 0.5, delay := 0.0):
	if not target or not target is CanvasItem:
		push_error("fade_in_node: Target must be a CanvasItem.")
		return

	target.modulate.a = 0.0
	target.show()

	var tween = target.get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "modulate:a", 1.0, duration).set_delay(delay)

func fade_out_node(target: CanvasItem, duration := 0.5, delay := 0.0):
	if not target or not target is CanvasItem:
		push_error("fade_out_node: Target must be a CanvasItem.")
		return

	var tween = target.get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(target, "modulate:a", 0.0, duration).set_delay(delay)
	tween.tween_callback(Callable(target, "hide"))

func fade_out_node_queue(target: CanvasItem, duration := 0.5, delay := 0.0):
	if not target or not target is CanvasItem:
		push_error("fade_out_node: Target must be a CanvasItem.")
		return

	var tween = target.get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(target, "modulate:a", 0.0, duration).set_delay(delay)
	tween.tween_callback(Callable(target, "queue_free"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("questoUI") and !questlog_shown:
		questlog_shown = true
		add_child(QuestLogClone)
		fade_in_node(QuestLogClone)
		print("show")
	elif Input.is_action_just_pressed("questoUI") and questlog_shown:
		questlog_shown = false
		fade_out_node(QuestLogClone)
		print("hifde")
