extends Area2D

var collided_local_player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$TelegraphStartTimeTimer.start()

func initialize(attack_data, players):
	position.x = attack_data["position"][0]
	position.y = attack_data["position"][1]
	$TelegraphStartTimeTimer.wait_time =  attack_data["telegraph_start_time"]
	$DamageStartReltimeTimer.wait_time = attack_data["damage_start_reltime"]
	$DamageDurationTimer.wait_time = attack_data["damage_duration"]
	$DamageTickTimer.wait_time = attack_data["damage_tick_time"]
	$Sprite2D.scale = Vector2(attack_data["radius_mult"], attack_data["radius_mult"])
	$Sprite2D.hide()
	$Sprite2D.z_index = -3
	# Make sure 'local to scene' is checked for $CollisionShape2D!!
	$CollisionShape2D.shape.radius *= attack_data["radius_mult"] # DO NOT EDIT SCALE 
	print("radius: " + str($CollisionShape2D.shape.radius))
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_telegraph_start_time_timer_timeout():
	$DamageStartReltimeTimer.start()
	$Sprite2D.show()
	pass

func _on_damage_start_reltime_timer_timeout():
	$DamageDurationTimer.start()
	$Sprite2D.texture = preload("res://Scenes/Attacks/AOECircle/AOECircleActive.png")
	#$CollisionShape2D.set_deferred("disabled", false)
	$CollisionShape2D.disabled = false
	pass
	
func _on_damage_duration_timer_timeout():
	# remove aoecircle node from scenetree. 
	queue_free()

func _on_area_entered(area):
	if "is_local_player" in area and area.is_local_player:
		if $DamageTickTimer.time_left == 0:
			area.take_hit()
			$DamageTickTimer.start()
		collided_local_player = area

func _on_area_exited(area):
	if "is_local_player" in area and area.is_local_player:
		collided_local_player = null

func _on_damage_tick_timer_timeout():
	if collided_local_player != null:
		collided_local_player.take_hit()
		$DamageTickTimer.start()
