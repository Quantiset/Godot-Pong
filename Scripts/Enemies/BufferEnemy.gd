extends StandardEnemy
class_name BufferEnemy


func die():
	
	for enemy in $Influence.get_overlapping_bodies():
		enemy.get_node("AnimationPlayer").play("Buffed")
		enemy.boost()
	
	.die()
