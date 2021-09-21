extends Bullet

var rot: float
var speed: float


func _ready():
	velocity = Vector2(speed,0).rotated(rot)

func _physics_process(delta: float) -> void:
	position += velocity
	$Line2D.rotation = rot
	$CollisionShape2D.rotation = rot

