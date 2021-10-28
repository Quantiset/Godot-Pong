extends StandardEnemy
class_name BufferEnemy


func die():
	
	for enemy in $Influence.get_overlapping_bodies():
		if enemy.has_node("AnimationPlayer"):
			enemy.get_node("AnimationPlayer").play("Buffed")
		
		if enemy.has_method("boost"):
			enemy.boost()
	
	.die()
