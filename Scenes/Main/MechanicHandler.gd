extends Node

static var Enums = preload("res://Scenes/Main/Enums.gd")
static var Utils = preload("res://Scenes/Main/Utils.gd")

static func mechanic_handler(mechanic_enum, players):
	print("Loading mechanic enum: " + str(mechanic_enum))
	var mech_data
	var mech_name
	# maps mechanic enum to json file containing its definition
	if mechanic_enum == Enums.Mechanics.RandomBS1:
		mech_data = Utils.load_json_file("res://Mechanics/RandomBS1.json")
		mech_name = "RandomBS1"
	else:
		assert(false, 'unhandled mechanic')
		
	# parses mech_data into mechanic object
	return build_mechanic(mech_data, players)
	
static func build_mechanic(mech_data, players):
	var mechanic = Node.new()
	for attack_data in mech_data:
		mechanic.add_child(build_attack(attack_data, players))
	return mechanic
	
static func build_attack(attack_data, players):
	var attack_name = attack_data["mechanic_obj_type"]
	print("Building attack: " + str(attack_name))
	var attack = load("res://Scenes/Attacks/" + attack_name + "/" + attack_name + ".tscn").instantiate()
	attack.initialize(attack_data, players)
	return attack 
	
