extends Node2D

var player_ids = []
var player_names = {}
var player_role_enums = {}
var network_id = -1

var Enums = load("res://Scenes/Main/Enums.gd")
var local_player_character

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func initialize(player_ids, player_name_dict, player_role_enum_dict):
	network_id = player_ids[0] # my network id is the first in the list.
	for id in player_ids:
		var player = preload("res://Scenes/Main/Player.tscn").instantiate()
		player.initialize(id, player_name_dict[str(id)], player_role_enum_dict[str(id)], network_id)
		add_child(player)
		if id == network_id:
			local_player_character = player
	print(str(network_id) + " finished initializing players!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	$SprintCDValLabel.set_text(str(int(local_player_character.get_node("SprintCooldownTimer").time_left)))
	$SprintDurationValLabel.set_text(str(int(local_player_character.get_node("SprintDurationTimer").time_left)))
	pass
