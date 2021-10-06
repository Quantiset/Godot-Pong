extends Area2D

var type: GDScript

const DESC_HEIGHT = 30
const DESC_FADE_LENGTH = 4


func _ready():
	var metadata = type._metadata()
	$Sprite.texture = metadata.texture
	$AnimationPlayer.play("Shine")
	$DescriptionPopup/Label.text = metadata.item_name
	$DescriptionPopup/Label2.text = metadata.description


func _on_Item_body_entered(body):
	if body.is_in_group("Player"):
		body.add_item(type)
		delete()

func delete():
	
	$Sprite.visible = false
	$DescriptionPopup.visible = true
	$Tween.interpolate_property(
		$DescriptionPopup, 
		"modulate", 
		Color(1,1,1), 
		Color(1,1,1,0), 
		DESC_FADE_LENGTH, 
		Tween.TRANS_LINEAR
	)
	$Tween.interpolate_property(
		$DescriptionPopup, 
		"rect_position:y", 
		$DescriptionPopup.rect_position.y, 
		$DescriptionPopup.rect_position.y - DESC_HEIGHT, 
		DESC_FADE_LENGTH, 
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)
	$Tween.start()
	
	yield($Tween, "tween_completed")
	
	queue_free()


