extends Node

static var Enums = preload("res://Scenes/Main/Enums.gd")
static var Utils = preload("res://Scenes/Main/Utils.gd")

static func mechanic_handler(mechanic_enum):
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
	return build_mechanic(mech_data)
	
static func build_mechanic(mech_data):
	var mechanic = Node.new()
	for attack_data in mech_data:
		mechanic.add_child(build_attack(attack_data))
	return mechanic
	
static func build_attack(attack_data):
	var attack_name = attack_data["mechanic_obj_type"]
	var attack = load("res://Scenes/Attacks/" + attack_name + "/" + attack_name + ".tscn").instantiate()
	attack.initialize(attack_data)
	return attack 
	
