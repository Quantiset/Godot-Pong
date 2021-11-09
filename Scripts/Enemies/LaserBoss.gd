extends Boss
class_name LaserBoss

onready var ref_rect: ReferenceRect = get_node("../ReferenceRect")
onready var centerofroom: Vector2 = ref_rect.rect_position + ref_rect.rect_size/2

const LASER_COLOR = Color(1, 1.2, 0.5)

enum States {
	FollowPlayerAndShoot
	LaserHell 
} 

var lasers := []

# init is for direct variable changes
func _ready():
	max_hp = 2500
	hp = max_hp
	max_speed = 100
	update_health()
	
	set_state(States.LaserHell)

func _physics_process(delta: float) -> void:
	
	for laser in lasers:
		if is_instance_valid(laser):
			laser.rotation += delta / 3
	
	match current_state:
		States.LaserHell:
			# go towards center of room
			velocity += (centerofroom - position).normalized() * 5
			velocity = velocity.clamped(max_speed)
			
			if position.distance_to(centerofroom) < 100:
				
				if is_zero_approx(fmod(time_in_this_state, 7)):
					
					var randfl := randf()
					var explosion_amount: int = 8 + (-5.0*hp/max_hp + 5)
					for i in range(explosion_amount):
						var b = preload("res://Scenes/Bullets/Laser.tscn")
						var b_inst = b.instance()
						b_inst.position = position
						b_inst.rotation = i*2*PI/explosion_amount + randfl
						b_inst.modulate = LASER_COLOR
						b_inst.get_node("AnimationPlayer").connect("animation_finished", self, "on_laser_warning_finished", [b_inst, true, 5])
						get_parent().call_deferred("add_child", b_inst)
				
				if time_in_this_state > 27:
					set_state(States.FollowPlayerAndShoot)
			
			rotation = velocity.angle() + PI/2
		States.FollowPlayerAndShoot:
			
			velocity = (player.position - position).normalized() * max_speed
			rotation = velocity.angle() + PI/2
			
			if is_zero_approx(fmod(time_in_this_state, 0.3)):
				var b = preload("res://Scenes/Bullets/Laser.tscn")
				var b_inst = b.instance()
				b_inst.position = position
				b_inst.rotation = (player.position - position).angle()
				b_inst.modulate = LASER_COLOR
				b_inst.get_node("AnimationPlayer").connect("animation_finished", self, "on_laser_warning_finished", [b_inst, false, 0.05])
				get_parent().call_deferred("add_child", b_inst)
			
			if time_in_this_state > 12:
				set_state(States.LaserHell)

func delete():
	for laser in lasers:
		if is_instance_valid(laser):
			laser.delete()
	.delete()


func on_laser_warning_finished(_str, laser, add_to_lasers: bool, time: float):
	if add_to_lasers:
		lasers.append(laser)
	var t := Timer.new()
	add_child(t)
	t.connect("timeout", self, "delete_laser", [laser])
	t.start(time)

func delete_laser(laser):
	if is_instance_valid(laser):
		if laser in lasers:
			lasers.erase(laser)
		laser.delete()
