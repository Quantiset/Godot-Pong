extends Bullet
class_name HomingBullet

onready var trail = $Node/Trail
var trail_length = 20

var target
var steer_force := 0.3

func _ready():
	$Detection.set_collision_mask_bit(Globals.BIT_PLAYER, get_collision_mask_bit(Globals.BIT_PLAYER))
	$Detection.set_collision_mask_bit(Globals.BIT_ENEMY, get_collision_mask_bit(Globals.BIT_ENEMY))
	velocity = Vector2(speed,0).rotated(rot)


func _physics_process(delta: float) -> void:
	
	if target:
		velocity += to_local(target.position).normalized() * steer_force
	
	velocity = velocity.normalized() *speed
	position += velocity * delta * 60
	
	trail.add_point(position)
	if trail.get_point_count() == trail_length:
		trail.remove_point(0) 
	
	var angle = velocity.angle()
	$Line2D.rotation = angle
	$CollisionShape2D.rotation = angle - PI/2


func _on_Detection_body_entered(body):
	if not body.has_method("take_damage"):
		return
	if not target:
		target = body

func _on_Detection_body_exited(body):
	target = null
