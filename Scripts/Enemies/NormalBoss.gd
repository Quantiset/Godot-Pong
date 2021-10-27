extends Boss

var time_until_last_charge := 3.0
var is_charging := false

enum States {
	ShootForward,
	ChargeAtPlayer
}

# init is for direct variable changes
func _ready():
	max_hp = 1250
	hp = max_hp
	max_speed = 100
	update_health()
	
	current_state = States.ChargeAtPlayer

func _physics_process(delta: float) -> void:
	
	match current_state:
		States.ShootForward:
			if randi() % 100 == 1:
				
				# -5x + 5 based on health. Increases shot amount as health decreases
				shot_amount = -5.0*hp/max_hp + 5
				
				shoot()
			
			for raycast in $Raycasts.get_children():
				if raycast.is_colliding():
					velocity *= -1
			
			velocity += (player.position - position).normalized() * max_speed
			velocity = velocity.clamped(max_speed)
			
			rotation = lerp_angle(rotation - PI/2, velocity.angle(), 0.2) + PI/2
			
			if damage_in_this_state > max_hp / 3 or time_in_this_state > 10:
				set_state(States.ChargeAtPlayer)
			
		
		States.ChargeAtPlayer:
			time_until_last_charge += delta
			
			if time_until_last_charge > 3:
				is_charging = true
				player.shake_amount += 2
				velocity = Vector2(max_speed*3,0).rotated((player.position - position).angle())
				time_until_last_charge = 0.0
			
			rotation = lerp_angle(rotation - PI/2, velocity.angle(), 0.2) + PI/2
			
			if damage_in_this_state > max_hp / 3 or time_in_this_state > 10:
				time_until_last_charge = 3.0
				is_charging = false
				set_state(States.ShootForward)


func shoot():
	var b_list: Array = .shoot()
	
	var i := 0
	
	# same as player. Iterates over and modifies fan range
	for bullet in b_list:
		
		#this is the current offset from the leftmostpoint of shot_fan_range
		var addon := i*shot_fan_range/b_list.size() - shot_fan_range/4
		if b_list.size() == 1:
			bullet.rot = rotation - PI/2
		else:
			bullet.rot = rotation - PI/2 + addon
		
		# set it to hit enemies, not the player itself
		bullet.set_collision_mask_bit(Globals.BIT_PLAYER, true)
		get_parent().add_child(bullet)
		i += 1





func _on_BuffRadius_body_entered(body):
	if body is StandardEnemy:
		body.modulate.a *= 1.2
		body.connect("shot", self, "on_Buffed_enemy_shot")

func _on_BuffRadius_body_exited(body):
	if body is StandardEnemy:
		body.modulate.a /= 1.2
		body.disconnect("shot", self, "on_Buffed_enemy_shot")

func on_Buffed_enemy_shot(bullet: Bullet):
	bullet.damage_multiplier *= 1.5
