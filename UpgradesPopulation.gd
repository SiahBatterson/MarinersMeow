extends ScrollContainer

@export var BoatUpgrades: Array
var unpacked_upgrades: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	$Upgrades.custom_minimum_size = Vector2(10, 10)  # non-zero default
	print("Upgrades size:", $Upgrades.size)

	for i in BoatUpgrades:
		unpacked_upgrades.append(i.instantiate())
	print(str(unpacked_upgrades))
	populate_upgrades()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func populate_upgrades():
	for x in $Upgrades.get_children():
		x.queue_free()

	unpacked_upgrades.sort_custom(func(a, b): return a.level_needed < b.level_needed)

	for i in unpacked_upgrades:
		if i.level_needed <= InventoryManager.level:
			$Upgrades.add_child(i)
			i.scale = Vector2(.7,.7)
			print("Adding Item")
		elif i.level_needed == InventoryManager.level + 1:
			$Upgrades.add_child(i)
			i.scale = Vector2(.7,.7)
			i.is_not_level = true
			print("Adding Item")
