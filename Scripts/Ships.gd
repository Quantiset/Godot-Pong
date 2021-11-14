extends Node


class ShipReference extends Resource:
	pass


class StandardShip extends ShipReference:
	
	static func _metadata() -> Dictionary:
		return {
			"scene": preload("res://Scenes/Players/Player.tscn"),
			"texture": preload("res://Assets/Player/Player.png"),
			"starting_items": [
				
			],
			"stats": {
				"speed": 50,
				"attack": 50,
				"health": 50,
			},
			"name": "Standard Ship",
			"description": "Originally used as a reconnaissance ship under the pseudonym 'Virtue'; although refitted hastily for combat, it is still a very viable ship in many regards",
			"unlock_description": ""
		}

class GreenShip extends ShipReference:
	
	static func _metadata() -> Dictionary:
		return {
			"scene": preload("res://Scenes/Players/GreenPlayer.tscn"),
			"texture": preload("res://Assets/Enemies/ShootAroundEnemy.png"),
			"starting_items": [
				Items.PanicButton, Items.PoisionMixture
			],
			"stats": {
				"speed": 40,
				"attack": 75,
				"health": 40,
			},
			"name": "Green Ship",
			"description": "Stable Quantum detonations in the drive core allow bullets to be materialistically produced by quantum means, carrying with it an ionizing ooze which penetrates metal",
			"unlock_description": "Kill the Wave 10 Boss"
		}

class LaserShip extends ShipReference:
	
	static func _metadata() -> Dictionary:
		return {
			"scene": preload("res://Scenes/Players/LaserPlayer.tscn"),
			"texture": preload("res://Assets/Player/LaserPlayer.png"),
			"starting_items": [
				Items.LaserBullet
			],
			"stats": {
				"speed": 40,
				"attack": 75,
				"health": 40,
			},
			"name": "Laser Ship",
			"description": "Harnessing the electrical systems present in those of opposing ships allows the development of a laser cannon mounted on the ship's interior. This inadvertantly causes the ship to move terribly slowly",
			"unlock_description": "Kill the Wave 15 Boss"
		}

class ScrapHoarder extends ShipReference:
	
	static func _metadata() -> Dictionary:
		return {
			"scene": preload("res://Scenes/Players/ScrapHoarder.tscn"),
			"texture": preload("res://Assets/Player/ScrapHoarder.png"),
			"starting_items": [
				Items.RefinedPlating
			],
			"stats": {
				"speed": 60,
				"attack": 35,
				"health": 65,
			},
			"name": "Scrap Hoarder",
			"description": "A rare ship built exclusively from scrap. On board is a scrap refinery which increases all scrap recieved by a small amount. However, a non-scrap metal deficiency forces low-grade bullets, reducing damage",
			"unlock_description": "Have 1000 scrap on you at a time"
		}
