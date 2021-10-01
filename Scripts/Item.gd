extends Area2D

var type: GDScript


func _ready():
	var metadata = type._metadata()
	$Sprite.texture = metadata.texture
	$AnimationPlayer.play("Shine")


func _on_Item_body_entered(body):
	if body.is_in_group("Player"):
		body.add_item(type)
		queue_free()
