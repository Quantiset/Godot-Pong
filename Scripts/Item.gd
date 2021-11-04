extends Area2D
class_name Item

var velocity := Vector2()

export var type: GDScript = Items.DoubledMuzzle setget set_type
var metadata: Dictionary
var id: int

export var paid := false
var price: int

const DESC_HEIGHT = 30
const DESC_FADE_LENGTH = 4

var has_picked_up := false

signal picked_up()

func _ready():
	if type:
		update_type()

func _physics_process(delta: float) -> void:
	position += velocity * delta * 60
	velocity = velocity.linear_interpolate(Vector2(), 0.1)

func update_type():
	metadata = type._metadata()
	id = metadata.id
	$Sprite.texture = metadata.texture
	$AnimationPlayer.play("Shine")
	$DescriptionPopup/Label.text = metadata.item_name
	$DescriptionPopup/Label2.text = metadata.description
	#scrap
	if id < 0:
		set_collision_layer_bit(Globals.BIT_SCRAP, true)
		$AnimationPlayer2.play("Vibrate")
	else:
		set_collision_layer_bit(Globals.BIT_SCRAP, false)
		$AnimationPlayer2.stop(true)
	
	if paid:
		$PriceLabel.show()
		price = Globals.RARITIES_PRICE[metadata.rarity]
		$PriceLabel.text = str(price)
	else:
		$PriceLabel.hide()

func set_type(_type):
	type = _type
	update_type()

func _on_Item_body_entered(body):
	if body.is_in_group("Player") and not has_picked_up:
		if id < 0:
			# better scrap items have increased scrap values
			body.scrap += abs(id) * 10
		else:
			
			# if paid is set to true, meaning the player has to pay for it
			if paid:
				# if player doesn't have enough scrap to purchase it, return
				if body.scrap < price:
					return
				
				# subtract player's scrap
				body.scrap -= price
			
			# return value specifies whether object should get deleted or not
			if not pickup(body):
				return
			
		
		emit_signal("picked_up")
		delete()
		has_picked_up = true

# function intended to be overriden for other items
# return true if object should get deleted
func pickup(player) -> bool:
	player.add_item(type)
	return true

func delete():
	
	collision_layer = 0
	collision_mask = 0
	velocity = Vector2()
	
	$PriceLabel.visible = false
	$Sprite.visible = false
	$DescriptionPopup.visible = true
	$Tween.interpolate_property(
		$DescriptionPopup, 
		"modulate", 
		Color(1,1,1), 
		Color(1,1,1,0), 
		DESC_FADE_LENGTH, 
		Tween.TRANS_QUAD,
		Tween.EASE_IN
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


