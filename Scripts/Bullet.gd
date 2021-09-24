extends Area2D
class_name Bullet

onready var raycast: RayCast2D = $CollisionShape2D/RayCast2D


var velocity := Vector2()

var pierces := 0


func _physics_process(delta: float) -> void:
	raycast.cast_to = velocity*3
	raycast.force_raycast_update()

func _on_Bullet_body_entered(body):
	collide(body)

func collide(body):
	
	if body is RigidBody2D:
		body.apply_central_impulse(velocity.normalized() * 20)
	
	if body.has_method("take_damage"):
		body.take_damage(25)
	
	if pierces == 0:
		if not is_queued_for_deletion():
			delete()
	else:
		pierces -= 1

func delete():
	$Particles2D.emitting = false
	Globals.remove_particle($Particles2D)
	
	$ExplosionParticles.emitting = true
	Globals.remove_particle($ExplosionParticles)
	$ExplosionParticles2.emitting = true
	Globals.remove_particle($ExplosionParticles2)
	
	queue_free()
