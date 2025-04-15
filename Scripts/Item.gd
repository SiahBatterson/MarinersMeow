extends Node2D
class_name Item

@export var item_name: String = ""
@export var icon: Texture2D
@export var is_stackable: bool = false
@export var quality = "common"
@export var value = 0
@export var weaponType: String
@export var durability: int
@export var damage: int
@export var weight: int
@export var required_crafting_level: int = 1
@export var type: String = "none"

@export var isCraftable: bool
@export var crafting_recipe: Dictionary

func _ready():
	add_to_group("items")
	
