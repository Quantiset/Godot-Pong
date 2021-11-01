extends Boss

onready var ref_rect: ReferenceRect = get_node("../ReferenceRect")
onready var centerofroom: Vector2 = ref_rect.rect_position + ref_rect.rect_size/2

enum States {
	BulletHell
	LaserHell
} 

# init is for direct variable changes
func _ready():
	max_hp = 1750
	hp = max_hp
	max_speed = 100
	update_health()
	
	set_state(States.LaserHell)

func _physics_process(delta: float) -> void:
	
	match current_state:
		States.BulletHell:
			# go towards center of room
			velocity += (centerofroom - position).normalized() * 5
			velocity = velocity.clamped(max_speed)
			
			if position.distance_to(centerofroom) < 100:
				
				if is_zero_approx(fmod(time_in_this_state, 0.3)):
					
					var randfl := randf()
					var explosion_amount: int = 8 + (-5.0*hp/max_hp + 5)
					for i in range(explosion_amount):
						var b = preload("res://Scenes/Bullets/StraightBullet.tscn")
						var b_inst = b.instance()
						b_inst.position = position
						b_inst.rot = i*2*PI/explosion_amount + randfl
						b_inst.modulate = Color(0.628304, 0.996094, 0.564194)
						b_inst.speed = 5
						b_inst.set_collision_mask_bit(Globals.BIT_PLAYER, true)
						get_parent().call_deferred("add_child", b_inst)
				
				if time_in_this_state > 10:
					set_state(States.LaserHell)
			
		States.LaserHell:
			# go towards center of room
			velocity += (centerofroom - position).normalized() * 5
			velocity = velocity.clamped(max_speed)
			
			if position.distance_to(centerofroom) < 100:
				
				if is_zero_approx(fmod(time_in_this_state, 2)):
					
					var randfl := randf()
					var explosion_amount: int = 8 + (-5.0*hp/max_hp + 5)
					for i in range(explosion_amount):
						var b = preload("res://Scenes/Bullets/Laser.tscn")
						var b_inst = b.instance()
						b_inst.position = position
						b_inst.rotation = i*2*PI/explosion_amount + randfl
						b_inst.modulate = Color(0.628304, 0.996094, 0.564194)
						b_inst.get_node("AnimationPlayer").connect("animation_finished", self, "on_laser_warning_finished", [b_inst])
						get_parent().call_deferred("add_child", b_inst)
				
				if time_in_this_state > 10:
					set_state(States.BulletHell)
			
			rotation = velocity.angle() + PI/2




func on_laser_warning_finished(_str, laser):
	var t = Timer.new()
	add_child(t)
	t.connect("timeout", self, "delete_laser", [laser])
	t.start(1)

func delete_laser(laser):
	if is_instance_valid(laser):
		laser.delete()

