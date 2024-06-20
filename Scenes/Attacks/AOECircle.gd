extends RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$TelegraphStartTimeTimer.start()

func initialize(attack_data):
	position.x = attack_data["position"][0]
	position.y = attack_data["position"][1]
	$TelegraphStartTimeTimer.wait_time =  attack_data["telegraph_start_time"]
	$DamageStartReltimeTimer.wait_time = attack_data["damage_start_reltime"]
	$DamageDurationTimer.wait_time = attack_data["damage_duration"]
	$Sprite2D.scale = Vector2(attack_data["radius_mult"], attack_data["radius_mult"])
	$Sprite2D.hide()
	$Sprite2D.z_index = -3
	$CollisionShape2D.shape.radius *= attack_data["radius_mult"] # DO NOT EDIT SCALE 
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
	$Sprite2D.texture = preload("res://Assets/AOECircleActive.png")
	#$CollisionShape2D.set_deferred("disabled", false)
	$CollisionShape2D.disabled = false
	pass
	
func _on_damage_duration_timer_timeout():
	# remove aoecircle node from scenetree. 
	queue_free()
