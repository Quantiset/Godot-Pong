extends Area2D

export var heal_amount := 20

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Vibrate")


func _on_HealthDrop_body_entered(body):
	if body.name == "Player":
		body.take_damage(-heal_amount)
		queue_free()
