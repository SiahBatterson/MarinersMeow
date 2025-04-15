extends AnimatedSprite2D

@onready var animator = $"."
var hotspot_fish
@export var FishingUI: Node
var hotspotInReach = false

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.connect("hotspotReached",Callable(self,"Hotspot"))
	pass # Replace with function body.

func Hotspot(hotspot):
	hotspotInReach = true
	hotspot_fish = hotspot.fish
	if InventoryManager.msq_tracker == 1:
		DialogOrchestrator.start_dialog_set("MayorWhiskers", "fishing_tutorial")
	print("Hotspot in reach")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("e") and hotspotInReach:
		FishingUI.visible = !FishingUI.visible
		print("Fishing UI Visible")



func _on_animation_finished():
	if animator.animation == "Intro":
		animator.play("Default")


func _on_detection_area_entered(area):
	if area.is_in_group("Hotspot"):
		$"../Interactable".show()
		start_pulse($"../Interactable",Vector2(1,1),.5)
		
		
var pulse_active := false

func start_pulse(node: Node, target_scale: Vector2 = Vector2(1.1, 1.1), duration: float = 0.5):
	if pulse_active:
		return
	pulse_active = true
	_pulse_loop(node, target_scale, duration)

func _pulse_loop(node: Node, target_scale: Vector2, duration: float) -> void:
	# Fire and forget coroutine
	call_deferred("_run_pulse", node, target_scale, duration)

func _run_pulse(node: Node, target_scale: Vector2, duration: float) -> void:
	while pulse_active:
		var tween = node.create_tween()
		tween.tween_property(node, "scale", target_scale, duration / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(node, "scale", Vector2(1, 1), duration / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		await tween.finished  # Wait for both steps to finish

func stop_pulse():
	pulse_active = false




func _on_detection_area_exited(area):
	if area.is_in_group("Hotspot"):
		$"../Interactable".hide()
		start_pulse($"../Interactable",Vector2(1,1),.5)
