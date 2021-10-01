extends StandardEnemy
class_name ExplodingEnemy

export var explosion_amount := 8


func die():
	
	for i in range(explosion_amount):
		var b = preload("res://Scenes/Bullets/StraightBullet.tscn")
		var b_inst = b.instance()
		b_inst.position = position
		b_inst.rot = i*2*PI/explosion_amount
		b_inst.modulate = Color(0.618181, 0.996094, 0.564194)
		b_inst.speed = 5
		override_exploding_shot(b_inst)
		b_inst.set_collision_mask_bit(Globals.BIT_PLAYER, true)
		get_parent().call_deferred("add_child", b_inst)
	
	.die()

func override_exploding_shot(_bullet):
	pass
