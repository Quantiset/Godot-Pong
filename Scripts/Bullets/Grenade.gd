extends Area2D


var rot := 0.0
var velocity := Vector2()
var speed := 5

var damage := 50

var timeout := 2

var overlapping := []

onready var line := $Node/Line2D
var line_length := 10

func _ready():
	velocity = Vector2(speed, 0).rotated(rot)
	$TimeoutTimer.start(timeout)

func _physics_process(delta: float) -> void:
	position += velocity * delta * 60
	velocity = velocity.linear_interpolate(Vector2(), 0.02)
	
	line.add_point(position)
	if line.get_point_count() > line_length:
		line.remove_point(0)

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
		queue_free()


func _on_LargeArea_body_entered(body):
	if body.has_method("take_damage"):
		overlapping.append(body)


func _on_LargeArea_body_exited(body):
	if body.has_method("take_damage"):
		overlapping.erase(body)
