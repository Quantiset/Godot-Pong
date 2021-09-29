extends StandardEnemy

export var explosion_amount := 8


func die():
	
	for i in range(explosion_amount):
		var b = preload("res://Scenes/Bullets/StraightBullet.tscn")
		var b_inst = b.instance()
		b_inst.position = position
		b_inst.rot = i*2*PI/explosion_amount
		b_inst.speed = 5
		b_inst.set_collision_mask_bit(Globals.BIT_PLAYER, true)
		get_parent().call_deferred("add_child", b_inst)
	
	.die()
