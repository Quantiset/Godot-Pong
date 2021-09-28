extends Bullet
class_name StraightBullet

func _ready():
	velocity = Vector2(speed,0).rotated(rot)

func _physics_process(delta: float) -> void:
	position += velocity * delta * 60
	$Line2D.rotation = rot
	$CollisionShape2D.rotation = rot - PI/2
