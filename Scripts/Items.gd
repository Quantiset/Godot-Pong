extends Node

enum RARITIES {
	Common, #white
	Rare, #blue
	Ultra, #red
	Legendary, #Yellow
}

class ItemReference extends Resource:
	
	static func _metadata() -> Dictionary:
		return {
			"id": -1,
			"charge": -1,
			"rarity": Items.RARITIES.Common,
			"item_name": "NotImplemented",
			"texture": preload("res://Assets/HealthIcon.png"),
			"description": """
			
			"""
		}
	
	func _init2(emitter: Actor):
		pass
	
	func _on_shot(bullet: Array):
		pass
	
	func _input(inputevent):
		pass
	
	func _process(delta: float):
		pass
	
	func _activated(emitter):
		pass


class LeadTippedDarts extends ItemReference:
	
	static func _metadata():
		return {
			"id": 1,
			"charge": -1,
			"rarity": Items.RARITIES.Common,
			"item_name": "Lead Tipped Bullets",
			"texture": preload("res://Assets/Items/LeadTippedDarts.png"),
			"description": """
			Heavier bullets penetrate ships
			"""
		}
	
	func _init(emitter: Actor):
		pass
	
	func _on_shot(bullet_list: Array):
		for bullet in bullet_list:
			bullet.damage += 15
			bullet.pierces += 1

class RubberBullets extends ItemReference:
	
	static func _metadata() -> Dictionary:
		return {
			"id": 2,
			"charge": -1,
			"rarity": Items.RARITIES.Common,
			"item_name": "Rubber Tipped Bullets",
			"texture": preload("res://Assets/Items/RubberTippedBullets.png"),
			"description": """
			Elastisizes the bullets, granting bounce
			"""
		}
	
	func _init(emitter):
		pass
	
	func _on_shot(bullet_list: Array):
		for bullet in bullet_list:
			bullet.modulate = Color(0.605469, 0.833557, 1, 0.75)
			bullet.scale *= 0.75
			bullet.damage -= 10
			bullet.bounces += 1

class HeatseekingMissiles extends ItemReference:
	
	var is_first := false
	
	static func _metadata():
		return {
			"id": 3,
			"charge": -1,
			"rarity": Items.RARITIES.Ultra,
			"item_name": "Heatseeking Missiles",
			"texture": preload("res://Assets/Items/HeatseekingMissiles.png"),
			"description": """
			Grants Firefight
			"""
		}
	
	func _init(emitter):
		emitter.shot_cooldown_multiplier *= 1.3
		
		emitter.bullet = preload("res://Scenes/Bullets/HeatseekingBullet.tscn")
	
	func _init2(emitter):
		emitter.shot_cooldown_multiplier *= 0.8
		is_first = true
	
	func _on_shot(bullet_list: Array):
		for bullet in bullet_list:
			bullet.speed -= 6
			bullet.damage += 5 * (1 if is_first else 3)

class RefinedPlating extends ItemReference:
	
	static func _metadata():
		return {
			"id": 4,
			"charge": -1,
			"rarity": Items.RARITIES.Common,
			"item_name": "Refined Plating",
			"texture": preload("res://Assets/Items/RefinedPlating.png"),
			"description": """
			Enhanced alloys of steel cause heightened structural integrity and speed
			"""
		}
	
	func _init(emitter):
		emitter.max_hp += 50
		emitter.hp += 50
		emitter.max_speed += 50
	
	func _init2(emitter):
		emitter.max_speed -= 40

class DoubledMuzzle extends ItemReference:
	
	static func _metadata():
		return {
			"id": 5,
			"charge": -1,
			"rarity": Items.RARITIES.Rare,
			"item_name": "Doubled Muzzle",
			"texture": preload("res://Assets/Items/DoubledMuzzle.png"),
			"description": """
			Double the holes, double the fun
			"""
		}
	
	func _init(emitter):
		emitter.shot_amount += 1

class Grenade extends ItemReference:
	
	var emitter
	
	static func _metadata():
		return {
			"id": 6,
			"charge": -1,
			"rarity": Items.RARITIES.Common,
			"item_name": "Grenade",
			"texture": preload("res://Assets/Items/Grenade.png"),
			"description": """
			while (true) {
				explode()
			}
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
			g.damage = bullet_list[0].damage * 2
			g.get_node("Sprite").rotation = g.rot
			emitter.get_parent().add_child(g)

class MachineGun extends ItemReference:
	
	var is_first := true
	
	static func _metadata():
		return {
			"id": 7,
			"charge": -1,
			"rarity": Items.RARITIES.Legendary,
			"item_name": "Machine Gun",
			"texture": preload("res://Assets/Items/MachineGun.png"),
			"description": """
			
			"""
		}
	
	func _init(emitter):
		emitter.shot_cooldown /= 4
	
	func _init2(emitter):
		emitter.shot_cooldown *= 4
		emitter.shot_cooldown -= 0.1
		is_first = false
	
	func _on_shot(bullet_list: Array):
		for bullet in bullet_list:
			if is_first:
				bullet.damage_multiplier /= 3
			else:
				bullet.damage -= 1

class EnhancedTreads extends ItemReference:
	
	static func _metadata():
		return {
			"id": 8,
			"charge": -1,
			"rarity": Items.RARITIES.Common,
			"item_name": "Enhanced Treads",
			"texture": preload("res://Assets/Items/EnhancedTreads.png"),
			"description": """
			
			"""
		}
	
	func _init(emitter):
		emitter.max_speed += 100

class TeslaCoil extends ItemReference:
	
	static func _metadata():
		return {
			"id": 9,
			"charge": -1,
			"rarity": Items.RARITIES.Rare,
			"item_name": "Tesla Coil",
			"texture": preload("res://Assets/Items/TeslaCoil.tres"),
			"description": """
			And the ball was electric...
			"""
		}
	
	func _init(emitter):
		pass
	
	func _on_shot(bullet_list: Array):
		for bullet in bullet_list:
			bullet.connect("hit_object", self, "on_bullet_hit", [bullet])
	
	func on_bullet_hit(object, bullet: Bullet):
		
		var bullet_damage := bullet.get_total_damage()
		var enemies_hit = [object]
		var last_object = bullet
		
		for i in range(3):
			
			if not is_instance_valid(last_object):
				break
			
			# closest enemy from last enemy
			var closest_enemy: Node2D = Globals.get_closest_enemy_from(last_object.position, enemies_hit)
			
			# the line to use
			var l := Line2D.new()
			l.z_index = 2
			l.default_color = Color(1.3,1.3,1.3)
			l.texture = preload("res://Assets/Particles+Misc/spark_07.png")
			l.texture_mode = Line2D.LINE_TEXTURE_TILE
			l.begin_cap_mode = Line2D.LINE_CAP_ROUND
			l.end_cap_mode = Line2D.LINE_CAP_ROUND
			l.width = 40
			
			Globals.get_node("/root").add_child(l)
			
			var t := Tween.new()
			l.add_child(t)
			t.interpolate_property(l, "modulate", Color(1,1,1), Color(1,1,1,0), 0.25, Tween.TRANS_LINEAR)
			t.start()
			
			create_chain_from_to_with_line(last_object, closest_enemy, l)
			
			if is_instance_valid(closest_enemy) and last_object.to_local(closest_enemy.position).length() < 180:
				closest_enemy.take_damage(bullet_damage / 2)
				last_object = closest_enemy
			
			enemies_hit.append(closest_enemy)
			
			yield(Items.get_tree().create_timer(0.25), "timeout")
		
		#t.start()
	func create_chain_from_to_with_line(from: Node2D, to: Node2D, line: Line2D, max_length := 180):
		
		var pos: Vector2
		
		# if another close enemy doesn't exist or the closest enemy is too far, just attack a random area
		if not is_instance_valid(to) or from.to_local(to.position).length() > max_length:
			pos = Vector2(randf()-0.5, randf()-0.5).normalized() * 40
		else:
			pos = from.to_local(to.position)
		
		line.add_point(from.position)
		line.add_point(from.position + pos)

class Shank extends ItemReference:
	
	var emitter
	
	static func _metadata():
		return {
			"id": 9,
			"charge": 1,
			"rarity": Items.RARITIES.Common,
			"item_name": "Shank",
			"texture": preload("res://Assets/Items/Shank.png"),
			"description": """
			Backstabber
			"""
		}
	
	func _init(_emitter: Player):
		emitter = _emitter
		emitter.max_speed += 50
	
	func _activated(emitter: Player):
		var s := Sprite.new()
		s.texture = preload("res://Assets/Triangle.png")
		s.offset = Vector2(0, -32)
		s.rotation = emitter.get_local_mouse_position().angle() + PI/2
		emitter.add_child(s)
		
		var t := Tween.new()
		s.add_child(t)
		t.interpolate_property(s, "scale", Vector2(0,0), Vector2(1,1), 0.1, Tween.TRANS_LINEAR)
		t.start()
		
		yield(t, "tween_completed")
		
		yield(Items.get_tree().create_timer(0.5), "timeout")
		
		t.interpolate_property(s, "scale", Vector2(1,1), Vector2(0,0), 0.1, Tween.TRANS_LINEAR)
		t.start()
		
		yield(t, "tween_completed")
		
		s.queue_free()

class Overdrive extends ItemReference:
	
	var mult = 3
	
	static func _metadata():
		return {
			"id": 10,
			"charge": 15,
			"rarity": Items.RARITIES.Common,
			"item_name": "Overdrive",
			"texture": preload("res://Assets/Items/Overdrive.png"),
			"description": """
			Briefly increase attack rate by 300%
			"""
		}
	
	func _init(emitter: Actor):
		pass
	
	func _init2(emitter: Actor):
		mult -= 1.5
	
	func _activated(emitter: Player):
		emitter.shot_cooldown_multiplier /= mult
		
		yield(Items.get_tree().create_timer(4.0), "timeout")
		
		if is_instance_valid(emitter):
			emitter.shot_cooldown_multiplier *= mult
	
