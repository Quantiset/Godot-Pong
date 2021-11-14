extends Control


var ship_data := {
	0: Ships.StandardShip,
	1: Ships.GreenShip,
	2: Ships.LaserShip,
	3: Ships.ScrapHoarder,
}

const AMOUNT_OF_SQUARES = 56 

onready var stat_tween := $Tween

onready var sword_slider: TextureProgress = $ShipUI/StatIcons/Sword/Gradient
onready var health_slider: TextureProgress = $ShipUI/StatIcons/Plating/Gradient
onready var speed_slider: TextureProgress = $ShipUI/StatIcons/Lightning/Gradient

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		$Light2D.position = event.position

func _ready():
	for i in range(AMOUNT_OF_SQUARES):
		if ship_data.has(i):
			var ship_text: StreamTexture
			
			if Globals.unlocked_ships.has(i):
				ship_text = ship_data[i]._metadata().texture
			else:
				ship_text = preload("res://Assets/Player/PlayerLock.png")
			
			$ShipSelect/ItemList.add_icon_item(ship_text)
	
	_on_ItemList_item_selected(0)


func _on_ItemList_item_selected(index: int):
	var ship = ship_data[index]
	var metadata: Dictionary = ship._metadata()
	
	# adds the topleft selection stripe
	$Sprite.position = Vector2(439, 78) + Vector2((index % 8) * 67, (index / 8) * 67)
	
	if Globals.unlocked_ships.has(index):
		# sets the current player to the selected ship
		Globals.player_scene = metadata.scene
		
		# modifies name and title
		$ShipUI/NameLabel.text = metadata.name
		$ShipUI/Sprite.texture = metadata.texture
		
		# adds the "starts with items"
		$ShipUI/StartingItems/ItemList.clear()
		for item in metadata.starting_items:
			var item_metadata: Dictionary = item._metadata()
			$ShipUI/StartingItems/ItemList.add_icon_item(item_metadata.texture)
		
		# handles the stat sliders
		var stat_to_slider := {
			"speed": speed_slider,
			"health": health_slider,
			"attack": sword_slider
		}
		for stat in metadata.stats:
			var slider: TextureProgress = stat_to_slider[stat]
			var stat_amount = metadata.stats[stat]
			stat_tween.interpolate_property(slider, "value", slider.value, stat_amount, 0.5)
		stat_tween.start()
		
		# sets description
		$ShipUI/Description.text = metadata.description
	else:
		$ShipUI/NameLabel.text = "LOCKED!"
		$ShipUI/Sprite.texture = preload("res://Assets/Player/PlayerLock.png")
		$ShipUI/StartingItems/ItemList.clear()
		for slider in [speed_slider, health_slider, sword_slider]:
			stat_tween.interpolate_property(slider, "value", slider.value, 0, 0.5)
		stat_tween.start()
		$ShipUI/Description.text = metadata.unlock_description


func _on_Confirm():
	get_tree().change_scene("res://Scenes/MainMenu.tscn")
