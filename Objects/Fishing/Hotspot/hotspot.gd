extends TextureRect

@export var fish = []
@export var density: float

func _on_area_2d_area_entered(area):
	if area.is_in_group("Boat"):
		SignalBus.hotspotReached.emit(self)
