extends Enemy
class_name Turret

func _ready():
	max_speed = 0
	max_hp *= 2
	shoot_rate = 200

func _physics_process(delta: float) -> void:
	
	velocity = to_local(player.position)
	
	var angle = velocity.angle()
	
	if randi() % shoot_rate == 1 and is_visible:
		var b_inst = bullet.instance()
		b_inst.position = position
		b_inst.rot = velocity.angle()
		b_inst.speed = 10
		b_inst.set_collision_mask_bit(Globals.BIT_PLAYER, true)
		get_parent().add_child(b_inst)
	
	$Sprite.rotation = angle + PI/2
	$CollisionShape2D.rotation = angle+ PI/2
