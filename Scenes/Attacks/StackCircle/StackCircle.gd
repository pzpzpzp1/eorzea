extends Area2D

var Enums = preload("res://Scenes/Main/Enums.gd")
var collided_local_player = null
var target_player = null
var min_needed_to_soak = 0
var players = null
var players_in_me = {}
var keep_moving = true
var DamageTickTimer_wait_time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$TelegraphStartTimeTimer.start()

func set_target_player(target_priority):
	target_player = players[randi()%players.size()]
	for role_string in target_priority:
		var role_enum = Enums.Roles[role_string]
		for player in players:
			if player.player_role_enum == role_enum:
				target_player = player 
				return
				
func initialize(attack_data, players_arg):
	players = players_arg
	set_target_player(attack_data["target_priority"])
	min_needed_to_soak = attack_data["min_needed_to_soak"]
	$TelegraphStartTimeTimer.wait_time =  attack_data["telegraph_start_time"]
	$DamageStartReltimeTimer.wait_time = attack_data["damage_start_reltime"]
	$DamageDurationTimer.wait_time = attack_data["damage_duration"]
	DamageTickTimer_wait_time = attack_data["damage_tick_time"]
	$Sprite2D.scale = Vector2(attack_data["radius_mult"], attack_data["radius_mult"])
	$Sprite2D.hide()
	$Sprite2D.z_index = -3
	# Make sure 'local to scene' is checked for $CollisionShape2D!!
	$CollisionShape2D.shape.radius *= attack_data["radius_mult"] # DO NOT EDIT SCALE 
	print("radius: " + str($CollisionShape2D.shape.radius))
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target_player != null and keep_moving:
		position.x = target_player.position.x
		position.y = target_player.position.y	

func _on_telegraph_start_time_timer_timeout():
	$DamageStartReltimeTimer.start()
	$Sprite2D.show()
	pass

func _on_damage_start_reltime_timer_timeout():
	keep_moving = false
	$DamageDurationTimer.start()
	$Sprite2D.texture = preload("res://Scenes/Attacks/StackCircle/StackCircleActive.png")
	$CollisionShape2D.disabled = false
	$DamageTickTimer.start(0.05) # give time to register players in stack before damage can hitw
	pass
	
func _on_damage_duration_timer_timeout():
	queue_free()

func _on_area_entered(area):
	if "is_local_player" in area:
		players_in_me[str(area.player_id)] = area
		if area.is_local_player:
			collided_local_player = area
			if $DamageTickTimer.time_left == 0:
				if players_in_me.size() < min_needed_to_soak:
					area.take_hit()
					$DamageTickTimer.start(DamageTickTimer_wait_time)
			
func _on_area_exited(area):
	if "is_local_player" in area:
		players_in_me.erase(str(area.player_id))
		if area.is_local_player:
			collided_local_player = null
			
		if players_in_me.size() < min_needed_to_soak and collided_local_player != null:
			collided_local_player.take_hit()
			$DamageTickTimer.start(DamageTickTimer_wait_time)
		
func _on_damage_tick_timer_timeout():
	if collided_local_player != null:
		if players_in_me.size() < min_needed_to_soak:
			collided_local_player.take_hit()
			$DamageTickTimer.start(DamageTickTimer_wait_time)
