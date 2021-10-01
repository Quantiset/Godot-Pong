extends Node

class ItemReference extends Resource:
	
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
			"id": 1,
			"item_name": "Lead Tipped Bullets",
			"texture": preload("res://Assets/Items/LeadTippedDarts.png"),
			"description": """
			+10 Damage \n
			+1 Pierce
			"""
		}
	
	func _init(emitter):
		pass
	
	func _on_shot(bullet_list: Array):
		for bullet in bullet_list:
			bullet.damage += 15
			bullet.pierces += 1

class RubberBullets extends ItemReference:
	
	static func _metadata():
		return {
			"id": 2,
			"item_name": "Rubber Tipped Bullets",
			"texture": preload("res://Assets/Items/RubberTippedBullets.png"),
			"description": """
			
			"""
		}
	
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
			"id": 3,
			"item_name": "Heatseeking Missiles",
			"texture": preload("res://Assets/Items/HeatseekingMissiles.png"),
			"description": """
			
			"""
		}
	
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
			"id": 4,
			"item_name": "Refined Plating",
			"texture": preload("res://Assets/Items/RefinedPlating.png"),
			"description": """
			
			"""
		}
	
	func _init(emitter):
		emitter.max_hp += 50
		emitter.hp += 50
		emitter.max_speed += 100

class DoubledMuzzle extends ItemReference:
	
	static func _metadata():
		return {
			"id": 5,
			"item_name": "Doubled Muzzle",
			"texture": preload("res://Assets/Items/DoubledMuzzle.png"),
			"description": """
			
			"""
		}
	
	func _init(emitter):
		emitter.shot_amount += 1

class Grenade extends ItemReference:
	
	var emitter
	
	static func _metadata():
		return {
			"id": 6,
			"item_name": "Grenade",
			"texture": preload("res://Assets/Items/Grenade.png"),
			"description": """
			
			"""
		}
	
	func _init(_emitter):
		emitter = _emitter
	
	var shots := 0
	func _on_shot(bullet_list: Array):
		for bul in bullet_list:
			bul.damage -= 5
		shots += 1
		if shots % 5 == 1:
			var g = preload("res://Scenes/Bullets/Grenade.tscn").instance()
			g.position = emitter.position
			g.rot = emitter.to_local(emitter.aim_cursor.position).angle()
			g.get_node("Sprite").rotation = g.rot
			emitter.get_parent().add_child(g)

class MachineGun extends ItemReference:
	
	var is_first := true
	
	static func _metadata():
		return {
			"id": 7,
			"item_name": "Machine Gun",
			"texture": preload("res://Assets/Items/MachineGun.png"),
			"description": """
			
			"""
		}
	
	func _init(emitter):
		emitter.shot_cooldown /= 4
	
	func _nonfirst(emitter):
		emitter.shot_cooldown *= 4
		emitter.shot_cooldown -= 0.1
		is_first = false
	
	var shots := 0
	func _on_shot(bullet_list: Array):
		for bullet in bullet_list:
			if is_first:
				bullet.damage_multiplier /= 3
			else:
				bullet.damage -= 1
