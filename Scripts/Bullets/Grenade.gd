extends Area2D


var rot := 0.0
var velocity := Vector2()
var speed := 5

var damage := 50

var timeout := 2

var overlapping := []

func _ready():
	velocity = Vector2(speed, 0).rotated(rot)
	$TimeoutTimer.start(timeout)

func _physics_process(delta: float) -> void:
	position += velocity * delta * 60
	velocity = velocity.linear_interpolate(Vector2(), 0.05)

func _on_Grenade_body_entered(body):
	if body.has_method("take_damage"):
		explode()

func _on_TimeoutTimer_timeout():
	explode()

func explode():
	if not is_queued_for_deletion():
		for body in overlapping:
			body.take_damage(damage)
		$ExplosionParticles.emitting = true
		Globals.remove_particle($ExplosionParticles)
		$SmokeTrail.emitting = false
		Globals.remove_particle($SmokeTrail)
		queue_free()


func _on_LargeArea_body_entered(body):
	if body.has_method("take_damage"):
		overlapping.append(body)


func _on_LargeArea_body_exited(body):
	if body.has_method("take_damage"):
		overlapping.erase(body)
