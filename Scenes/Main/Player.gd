extends Area2D

const BASE_SPEED = 150

var display_name = ""
var player_id = -1
var network_id = -1
var player_role_enum = -1
var Enums = load("res://Scenes/Main/Enums.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	position.x = 320 + (randi() % 100) - 50
	position.y = 512 + (randi() % 100) - 50

func initialize(id, displayname, role_enum, network_id):
	#print("Initializing " + str(id) + " Name: " + displayname + " Role: " + str(role_enum))
	if id == network_id:
		# show highlight on self
		$BoldBorderSprite2D.show()
	
	# set globals
	display_name = displayname
	player_id = id 
	player_role_enum = role_enum
	network_id = network_id
	
	if role_enum == Enums.Roles.T1:
		$BodySprite2D.texture = load("res://Assets/T1.png")
	elif role_enum == Enums.Roles.T2:
		$BodySprite2D.texture = load("res://Assets/T2.png")
	elif role_enum == Enums.Roles.H1:
		$BodySprite2D.texture = load("res://Assets/H1.png")
	elif role_enum == Enums.Roles.H2:
		$BodySprite2D.texture = load("res://Assets/H2.png")
	elif role_enum == Enums.Roles.M1:
		$BodySprite2D.texture = load("res://Assets/M1.png")
	elif role_enum == Enums.Roles.M2:
		$BodySprite2D.texture = load("res://Assets/M2.png")
	elif role_enum == Enums.Roles.R1:
		$BodySprite2D.texture = load("res://Assets/R1.png")
	elif role_enum == Enums.Roles.R2:
		$BodySprite2D.texture = load("res://Assets/R2.png")
	else:
		assert(false, "unexpected role.")
	
	# set authority. every network client and server will run this for every player instance they make. so everyone agrees who has authority over what player instance.
	set_multiplayer_authority(id)
	name = str(get_multiplayer_authority())
	print("self:" + str(network_id) + " adds player named:" + displayname + " auth id:" +str(id)+" p.name:" + name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Is the master of the paddle.
	if is_multiplayer_authority():
		var velocity = Vector2.ZERO # The player's movement vector.
		if Input.is_action_pressed("move_right"):
			velocity.x += 1
		if Input.is_action_pressed("move_left"):
			velocity.x -= 1
		if Input.is_action_pressed("move_down"):
			velocity.y += 1
		if Input.is_action_pressed("move_up"):
			velocity.y -= 1
		if Input.is_action_pressed("sprint"):
			pass
		if velocity.length() > 0:
			velocity = velocity.normalized() * BASE_SPEED
		
		position += velocity * delta
		position = position.clamp(Vector2.ZERO, get_viewport_rect().size)

		rpc("remote_set_position", position)

@rpc("unreliable")
func remote_set_position(pos):
	position = pos
