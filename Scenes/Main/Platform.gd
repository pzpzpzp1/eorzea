extends Node2D

var player_ids = []
var player_names = {}
var player_role_enums = {}
var network_id = -1

var Enums = preload("res://Scenes/Main/Enums.gd")
var MechanicHandler = preload("res://Scenes/Main/MechanicHandler.gd")
var local_player_character
var players = []

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().current_scene == self:
		print("Debugging Platform scene.")
		initialize([1], {"1":"nam"}, {"1":Enums.Roles.T1}, Enums.Mechanics.RandomBS1)

func initialize(player_ids, player_name_dict, player_role_enum_dict, mechanic_enum):
	network_id = player_ids[0] # my network id is the first in the list.
	for id in player_ids:
		var player = preload("res://Scenes/Main/Player.tscn").instantiate()
		player.initialize(id, player_name_dict[str(id)], player_role_enum_dict[str(id)], network_id)
		add_child(player)
		if id == network_id:
			local_player_character = player
		players.append(player)
	print(str(network_id) + " finished initializing players!")
	
	# LOAD MECHANIC ONTO PLATFORM
	# Need Server to load add mechanic to tree, and rpc it onto tree for all clients. That way it's re-synchronized per attack.
	var mechanic = MechanicHandler.mechanic_handler(mechanic_enum, players)
	add_child(mechanic)
	pass

func _process(delta):
	$SprintCDValLabel.set_text(str(int(local_player_character.get_node("SprintCooldownTimer").time_left)))
	$SprintDurationValLabel.set_text(str(int(local_player_character.get_node("SprintDurationTimer").time_left)))
	$HitCounterLabel.set_text(str(int(local_player_character.hits)))
	pass
