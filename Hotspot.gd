extends TextureRect

@export var hotspotRarity: String
@export var fish = []
@export var density: float
var original_speed = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func tween_opacity_with_callback(node: Node, target_alpha: float, duration: float = 1.0):
	var tween = node.create_tween()
	var color = node.modulate
	color.a = target_alpha
	tween.tween_property(node, "modulate", color, duration)
	await tween.finished
	print("Tween finished!")
	
func tween_opacity(node: Node, target_alpha: float, duration: float = 1.0):
	var tween = node.create_tween()
	tween.tween_property(node, "modulate", node.modulate.with_a(target_alpha), duration)
	tween.finished.connect(_on_tween_finished)

func _on_tween_finished():
	queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Boat"):
		print("Hotspot reached by:", area.name)
		SignalBus.hotspotReached.emit(self)
