extends Node2D

var player_health
var player_stamina

signal updatePlayerInformation(health,stamina)
signal InventoryUpdate(addOrRemove, item, quantity:int)
signal DialogStatus(status)
signal debug_inventory()
signal UIReady(object)
signal inventoryTooltip(tooltip,type)
signal interactableNearby(ping)
signal craftingAllowed(trueorfalse)
signal openCrafting()
signal mouseTooltip(info)
signal craftingTooltip(ingredients: Dictionary, item_name: String)
signal hideCraftingTooltip()
signal InvVisible()
signal stopBoat()
signal startBoat()
signal CastOff()
signal hotspotReached(hotspot: Object)

#link
signal FishCaught()

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("updatePlayerInformation",Callable(self,"playerInformationUpdateFunction"))
	connect("inventoryTooltip",Callable(self,"Test"))
	connect("hotspotReached",Callable(self,"Test"))
	

func playerInformationUpdateFunction(health,stamina):
	player_health = health
	player_stamina = stamina
	
func Test(hotspot):
	print("Density of hotspot: " + str(hotspot.density))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
