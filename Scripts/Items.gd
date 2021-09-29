extends Node

class ItemReference extends Resource:
	
	static func id() -> int:
		return -1
	
	static func _metadata() -> Dictionary:
		return {
			"item_name": "NotImplemented",
			"texture": preload("res://Assets/HealthIcon.png"),
			"description": """
			
			"""
		}
	
	func _nonfirst(emitter):
		pass
	
	func _on_shot(bullet):
		pass

class LeadTippedDarts extends ItemReference:
	
	static func _metadata():
		return {
			"item_name": "Lead Tipped Bullets",
			"texture": preload("res://Assets/Items/LeadTippedDarts.png"),
			"description": """
			+10 Damage \n
			+1 Pierce
			"""
		}
	
	static func id():
		return 1
	
	func _init(emitter):
		pass
	
	func _on_shot(bullet_list: Array):
		for bullet in bullet_list:
			bullet.damage += 15
			bullet.pierces += 1

class RubberBullets extends ItemReference:
	
	static func _metadata():
		return {
			"item_name": "Rubber Tipped Bullets",
			"texture": preload("res://Assets/Items/RubberTippedBullets.png"),
			"description": """
			
			"""
		}
	
	static func id():
		return 2
	
	func _init(emitter):
		pass
	
	func _on_shot(bullet_list: Array):
		for bullet in bullet_list:
			bullet.modulate = Color(0.605469, 0.833557, 1)
			bullet.damage -= 10
			bullet.bounces += 1

class HeatseekingMissiles extends ItemReference:
	
	var is_first := false
	
	static func _metadata():
		return {
			"item_name": "Heatseeking Missiles",
			"texture": preload("res://Assets/Items/HeatseekingMissiles.png"),
			"description": """
			
			"""
		}
	
	static func id():
		return 3
	
	func _init(emitter):
		emitter.shot_cooldown += 0.4
		
		emitter.bullet = preload("res://Scenes/Bullets/HeatseekingBullet.tscn")
	
	func _nonfirst(emitter):
		emitter.shot_cooldown -= 0.2
		is_first = true
	
	func _on_shot(bullet_list: Array):
		for bullet in bullet_list:
			bullet.speed -= 6
			bullet.damage += 15

class RefinedPlating extends ItemReference:
	
	static func _metadata():
		return {
			"item_name": "Refined Plating",
			"texture": preload("res://Assets/Items/RefinedPlating.png"),
			"description": """
			
			"""
		}
	
	static func id():
		return 4
	
	func _init(emitter):
		emitter.max_hp += 50
		emitter.hp += 50
		emitter.max_speed += 100

class DoubledMuzzle extends ItemReference:
	
	static func _metadata():
		return {
			"item_name": "Doubled Muzzle",
			"texture": preload("res://Assets/Items/DoubledMuzzle.png"),
			"description": """
			
			"""
		}
	
	static func id():
		return 5
	
	func _init(emitter):
		emitter.shot_amount += 1

class Grenade extends ItemReference:
	
	var emitter
	
	static func _metadata():
		return {
			"item_name": "Grenade",
			"texture": preload("res://Assets/Items/Grenade.png"),
			"description": """
			
			"""
		}
	
	static func id():
		return 6
	
	func _init(_emitter):
		emitter = _emitter
	
	var shots := 0
	func _on_shot(bullet_list: Array):
		for bul in bullet_list:
			bul.damage = 0
		shots += 1
		if shots % 5 == 1:
			var g = preload("res://Scenes/Bullets/Grenade.tscn").instance()
			g.position = emitter.position
			g.rot = emitter.to_local(emitter.aim_cursor.position).angle()
			emitter.get_parent().add_child(g)

class MachineGun extends ItemReference:
	
	static func _metadata():
		return {
			"item_name": "Machine Gun",
			"texture": preload("res://icon.png"),
			"description": """
			
			"""
		}
	
	static func id():
		return 7
	
	func _init(emitter):
		emitter.shot_cooldown /= 4
	
	var shots := 0
	func _on_shot(bullet_list: Array):
		for bullet in bullet_list:
			bullet.damage /= 3.5
