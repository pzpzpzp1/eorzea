extends Control

@onready var start_button = $StartButton
@onready var playerlist = $PlayerVBoxContainer
@onready var rolelist = $RoleVBoxContainer
@onready var rolechoice = $RoleOptionsButton
@onready var linecontainer = $Container
@onready var MechanicOptions = $MechanicOptionsButton
@onready var status_text = $StatusLabel

var Enums = preload("res://Scenes/Main/Enums.gd")
#var mechanics = ["randomBS"]
var light_party_roles = ["T1","H1","M1","R1"]
var full_party_roles = ["T1","T2","H1","H2","M1","M2","R1","R2"]

var player_ids = []
var player_names = {}
var player_roles = {}
var party_type = -1
var player_labels = {}



# Called when the node enters the scene tree for the first time.
func _ready():
	if multiplayer.is_server():
		start_button.disabled = false
		$MechanicOptionsButton.disabled = false
	else:
		start_button.hide()
		$MechanicOptionsButton.hide()
		$MechanicLabel.hide()
	
	for mechanic in Enums.Mechanics:
		var mechanic_index = Enums.Mechanics[mechanic]
		MechanicOptions.add_item(mechanic, mechanic_index)
	MechanicOptions.select(0)
	
func set_party_type(id):
	party_type = id
	var roles = []
	if party_type==0:
		roles = light_party_roles
	else:
		roles = full_party_roles
		
	for role_index in roles.size(): 
		var role = roles[role_index]
		var newlabel = Label.new()
		newlabel.text = role
		newlabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		rolelist.add_child(newlabel)
	
		rolechoice.add_item(role, role_index)
	rolechoice.select(-1)
		
	#draw_roles()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_player(id, name):
	player_ids.append(id)
	player_names[str(id)] = name
	player_roles[str(id)] = -1
	
	var newlabel = Label.new()
	newlabel.text = name
	playerlist.add_child(newlabel)
	player_labels[str(id)] = newlabel
	pass
	
func draw_roles():
	if rolelist.get_child_count()==0:
		# cant draw before rolelist is populated
		return
	
	var myid = player_ids[0]
	var myname = player_names[str(myid)]
	
	# clear line container
	for child in linecontainer.get_children():
		child.queue_free()
	
	# add draw new lines based on current roles
	for id in player_ids:
		var name = player_names[str(id)]
		var role = player_roles[str(id)]
		
		if role != -1:
			var player_label = player_labels[str(id)]
			var role_label = rolelist.get_child(role)
			var position1 = player_label.get_screen_position()
			var position2 = role_label.get_screen_position()
		
			var line = Line2D.new()
			linecontainer.add_child(line)
			line.width = 2
			line.default_color = Color(1,0,0)
			position1.y = position1.y + 12
			position2.y = position2.y + 12
			position2.x = position2.x + 40
			position1.x = position1.x - 3
			line.points = [position1, position2]
	pass
	
func _on_role_options_button_item_selected(index):
	var myid = player_ids[0]
	rpc("inform_role_choice", myid, index)
	inform_role_choice(myid, index)
	pass 

@rpc("any_peer", "call_remote")
func inform_role_choice(chooser_id, choice):
	print(player_names[str(player_ids[0])] + " acknowledges " + player_names[str(chooser_id)] + " chose role " + str(choice))
	player_roles[str(chooser_id)] = choice
	
	draw_roles()

func _set_status(text):
	status_text.set_text("Status: " + text)

func has_duplicates(int_list):
	var seen = {}
	for num in int_list:
		if num in seen:
			return true  # Duplicate found
		seen[num] = true
	return false  # No duplicates
	
@rpc("any_peer", "call_remote")
func start_game():
	get_tree().get_root().get_child(0).is_game_started = true
	#get_tree().get_root().get_child(0).peer.close() # no work :( 
	var platform = load("res://Scenes/Main/Platform.tscn").instantiate()
	get_tree().get_root().add_child(platform)
	platform.initialize(player_ids, player_names, resolve_player_role_enums(player_roles, party_type), MechanicOptions.get_selected_id())
	platform.show()
	hide()

func _on_start_button_button_down():
	# make sure mechanic to practice is chosen
	if MechanicOptions.get_selected_id() == -1:
		_set_status("Choose a mechanic to practice.")
		return

	# make sure all players have picked roles
	var selected_roles = []
	for id in player_ids:
		if player_roles[str(id)] == -1:
			_set_status("All players must choose a role.")
			return
		selected_roles.append(player_roles[str(id)])
	if has_duplicates(selected_roles):
		_set_status("No duplicate roles allowed.")
		return
	
	# make sure all roles are chosen only once
	for id in player_ids:
		if player_roles[str(id)] == -1:
			_set_status("All players must choose a role.")
			return
			
	# initialize next scene
	rpc("start_game") # tell everyone else to start the game
	start_game() # start the game
	
func resolve_player_role_enums(player_roles, party_type):
	assert(party_type != -1)
	var roles = []
	if party_type==0:
		roles = light_party_roles
	else:
		roles = full_party_roles
	var player_role_enums = {}
	for pid_key in player_roles:
		var prole = player_roles[pid_key]
		player_role_enums[pid_key] = Enums.string_to_enum(roles[prole], Enums.Roles)
	return player_role_enums
	
