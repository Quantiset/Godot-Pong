extends Area2D
class_name Bullet

onready var raycast: RayCast2D = $CollisionShape2D/RayCast2D


var velocity := Vector2()


func _physics_process(delta: float) -> void:
	raycast.cast_to = velocity*3
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		collide(raycast.get_collider())

func _on_Bullet_body_entered(body):
	collide(body)

func collide(body):
	if not is_queued_for_deletion():
		delete()

func delete():
	Globals.remove_particle(self, $Particles2D, true)
	
	$ExplosionParticles.emitting = true
	Globals.remove_particle(self, $ExplosionParticles, false)
	$ExplosionParticles2.emitting = true
	Globals.remove_particle(self, $ExplosionParticles2, false)
	
	queue_free()
