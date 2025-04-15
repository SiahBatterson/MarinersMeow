extends Item
class_name FishingRod

@export var stuff: int = 1

func _ready():
	super._ready()
	add_to_group("fishing_rods")
