extends CharacterBody2D

# Upgrades Possible #
var rocket_boots = false

var SPEED: float = 220
@export var max_speed: float = 200
@export var speed_multiplier_per_frame: float = 3
@export var itemTest: PackedScene
@export var itemTest2: PackedScene
@onready var sprite = $Sprite2D
var no_movement = false
var can_move
var dash_direction = Vector2(1, 0)
const dash_speed = 700
var can_dash = true
var dashing = false
var idle = true
var accelerate = 15
var current_checkpoint = Vector2(1,1)
var upgrades: Array
var sprint = false
var stamina = 1200
@export var staminaBurn = 1
var health = 100
var craftingTableOpenable = false

func _ready():
	SPEED = max_speed
	SPEED = SPEED / 10
	SignalBus.InventoryUpdate.emit("Add", itemTest)
	SignalBus.connect("interactableNearby",Callable(self,"alert"))
	SignalBus.connect("craftingAllowed",Callable(self,"craftingSwitch"))

func craftingSwitch(trueorfalse):
	if trueorfalse == true:
		craftingTableOpenable = true
	else:
		craftingTableOpenable = false
		
		
func alert(ping):
	if ping:
		$Hint.visible = true
	else:
		$Hint.visible = false

func transport_to_location(location):
	position = location

func _physics_process(delta):
	var direction = Vector2.ZERO
	if Input.is_action_pressed("up"):
		direction.y -= 1
		sprite.play("walkup")
	if Input.is_action_pressed("down"):
		direction.y += 1
		sprite.play("walkdown")
	if Input.is_action_pressed("left"):
		direction.x -= 1
		sprite.play("walkleft")
	if Input.is_action_pressed("right"):
		direction.x += 1
		sprite.play("walkright")
		
	#Animation
		
	# Stop animation when idle
	if direction == Vector2.ZERO:
		sprite.stop()
	if Input.is_action_pressed("shift"):
		sprint = true
	if Input.is_action_just_released("shift"):
		sprint = false
	if Input.is_action_just_released("escape"):
		$Inventory_Manager.visible = !$Inventory_Manager.visible
	if Input.is_action_just_released("e") and craftingTableOpenable:
		SignalBus.openCrafting.emit()
	if Input.is_action_just_pressed("ui_accept"):
		SignalBus.InventoryUpdate.emit("Add", itemTest)
		SignalBus.InventoryUpdate.emit("Add", itemTest2)
	if stamina > 0 and stamina < 900:
		stamina += 1

	direction = direction.normalized()

	# Handle Dash
	if Input.is_action_just_pressed("f") and can_dash and stamina > 300:
		stamina -= 300
		dashing = true
		can_dash = false
		
		# Create and start the dash duration timer
		var dash_timer = Timer.new()
		dash_timer.wait_time = 0.15  # Set duration of dash (adjust as needed)
		dash_timer.one_shot = true
		dash_timer.timeout.connect(func():
			dashing = false
			dash_timer.queue_free()  # Remove timer after use
		)
		add_child(dash_timer)
		dash_timer.start()

	# Create and start the cooldown timer
	var dash_cooldown = Timer.new()
	dash_cooldown.wait_time = 1.0  # Set cooldown duration (adjust as needed)
	dash_cooldown.one_shot = true
	dash_cooldown.timeout.connect(func():
		can_dash = true
		dash_cooldown.queue_free()  # Remove timer after use
	)
	add_child(dash_cooldown)
	dash_cooldown.start()
	
	dash_direction = direction if direction.length() > 0 else dash_direction


	# Movement Logic
	if dashing:
		velocity = dash_direction * dash_speed

	else:
		if sprint and stamina > 0:
			velocity = direction * SPEED * 2.5
			stamina-=staminaBurn
		else:
			velocity = direction * SPEED
			if stamina < 100 and !Input.is_action_pressed("shift"):
				stamina += 1
		SignalBus.updatePlayerInformation.emit(health,stamina)


	if direction != Vector2.ZERO:
		idle = false


	else:
		idle = true


	if no_movement:
		velocity = Vector2.ZERO

	move_and_slide()

func _on_timer_timeout():
	dashing = false

func _on_dash_cooldown_timeout():
	accelerate = 7
	can_dash = true

func update_checkpoint(position_of_new_Point):
	current_checkpoint = position_of_new_Point

func death_screen():

	no_movement = true

func return_to_checkpoint():
	position = current_checkpoint
	no_movement = false


func _on_area_2d_area_entered(area):
	if area.is_in_group("interactable"):
		print("Interact")

func pause_player_movement(is_moving):
	no_movement = is_moving
	print("no_move")

func cheat_handler(cheatcode):
	if cheatcode == "kobe":
		print("kobe")

func tech_check(id, disassemble):
	upgrades.append(id)
	if "rb" in upgrades:
		rocket_boots = true

func tech_disassemble(id):
	if id in upgrades:
		if id == "rb":
			rocket_boots = false
		upgrades.erase(id)
		print("removed tech")
