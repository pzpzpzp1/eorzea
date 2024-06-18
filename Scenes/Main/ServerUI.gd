extends Control

var peer = ENetMultiplayerPeer.new()
var mypeerid = ""
var max_players = 4
var waitingroom = load("res://Scenes/Main/WaitingRoom.tscn").instantiate()
@onready var address = $IPLineEdit
@onready var partytypebutton = $PartyTypeButton
@onready var host_button = $Host
@onready var join_button = $Join
@onready var status_text = $StatusLabel
@onready var portLE = $PortLineEdit
@onready var nameLE = $NameLineEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	nameLE.set_text(nameLE.get_text() + str(randi()%100))
	
	waitingroom.hide()
	pass
	
func _peer_connected(player_id):
	#if you're connecting to anything you are already either server or client. meaning your name and id are locked in.
	print("User "+ str(player_id) + " Connected")
	await get_tree().create_timer(1).timeout
	
	var myid = multiplayer.get_unique_id()
	rpc_id(player_id, "add_me", myid, nameLE.get_text())
	rpc_id(player_id, "inform_role_choice", myid, waitingroom.rolechoice.get_selected_id())
	if multiplayer.is_server():
		rpc_id(player_id, "inform_party_type", partytypebutton.get_selected_id())
		
	pass

# An empty pipe through to waitingroom. Wow i feel like i architected this bad.
@rpc("any_peer", "call_remote")
func inform_role_choice(chooser_id, choice):
	waitingroom.inform_role_choice(chooser_id, choice)

@rpc("any_peer", "call_remote")
func inform_party_type(party_type):
	waitingroom.set_party_type(party_type)

@rpc("any_peer", "call_remote")
func add_me(player_id, new_player_name):
	waitingroom.add_player(player_id, new_player_name)
	pass
	
@rpc("any_peer", "call_remote")
func add_previously_connected_player_characters(player_ids, player_names):
	for index in player_ids.size(): 
		waitingroom.add_player(player_ids[index], player_names[index])
	
	

func _peer_disconnected(player_id):
	print("User "+ str(player_id) + " Disconnected")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _set_status(text):
	status_text.set_text("Status: " + text)

func _on_host_button_down():
	if partytypebutton.get_selected_id()==-1:
		return
	elif partytypebutton.get_selected_id()==0:
		max_players = 4
	else:
		max_players = 8
	var port = int(portLE.get_text())
	var err = peer.create_server(port, max_players)
	if err != OK:
		_set_status("Can't host, address in use. Error code: " + str(err))
		return
	peer.host.compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer
	mypeerid = multiplayer.get_unique_id()
	print("Server created. Max players: " + str(max_players) + ". Host peer ID: "+ str(mypeerid))
	
	# Move to waiting room scene
	host_button.set_disabled(true)
	join_button.set_disabled(true)
	nameLE.editable = false
	get_tree().get_root().add_child(waitingroom)
	waitingroom.show()
	waitingroom.add_player(mypeerid, nameLE.get_text())
	waitingroom.set_party_type(partytypebutton.get_selected_id())
	hide()
	
func _on_join_button_down():
	var ip = address.get_text()
	if not ip.is_valid_ip_address():
		_set_status("Invalid IP.")
		return
	var port = int(portLE.get_text())
	var err = peer.create_client(ip, port)
	if err != OK:
		# https://docs.godotengine.org/en/stable/classes/class_%40globalscope.html#enum-globalscope-error
		_set_status("Failed to connect to server. Error code:" + str(err))
		return
	peer.host.compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer
	mypeerid = multiplayer.get_unique_id()
	print("Joining game with peer ID: "+ str(mypeerid))
	_set_status("Connecting to server ...")

	# Move to waiting room scene
	host_button.set_disabled(true)
	join_button.set_disabled(true)
	nameLE.editable = false
	get_tree().get_root().add_child(waitingroom)
	waitingroom.show()
	waitingroom.add_player(mypeerid, nameLE.get_text())
	hide()

