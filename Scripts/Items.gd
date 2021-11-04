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
			"price": 100,
			"item_name": "NotImplemented",
			"texture": preload("res://Assets/HealthIcon.png"),
			"description": """
			
			"""
		}
	
	func _init2(emitter: Actor):
		pass
	
	func _on_shot(bullet: Array):
		pass
	
	func _damage_taken(damage: int):
		pass
	
	func _input(event):
		pass
	
	func _process(delta: float):
		pass
	
	func _activated(emitter: Player):
		pass

class Scrap extends ItemReference:
	static func _metadata():
		return {
			"id": -1,
			"charge": -1,
			"rarity": Items.RARITIES.Common,
			"price": 1,
			"item_name": "",
			"texture": preload("res://Assets/Scrap.png"),
			"description": """
			+10
			"""
		}
class BlueScrap extends ItemReference:
	static func _metadata():
		return {
			"id": -2,
			"charge": -1,
			"rarity": Items.RARITIES.Common,
			"price": 1,
			"item_name": "+20",
			"texture": preload("res://Assets/BlueScrap.png"),
			"description": """
			
			"""
		}

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
		emitter.shot_cooldown /= 2.5
	
	func _init2(emitter):
		emitter.shot_cooldown *= 2.5
		emitter.shot_cooldown -= 0.1
		is_first = false
	
	func _on_shot(bullet_list: Array):
		for bullet in bullet_list:
			if is_first:
				bullet.damage_multiplier /= 2
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
			
			Globals.add_child(l)
			
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

class Shellshock extends ItemReference:
	
	static func _metadata():
		return {
			"id": 11,
			"charge": -1,
			"rarity": Items.RARITIES.Common,
			"item_name": "Shellshock",
			"texture": preload("res://Assets/Items/Shellshock.png"),
			"description": """
			Increases stun duration on enemy hits
			"""
		}
	
	func _init(emitter: Actor):
		pass
	
	func _on_shot(bullet_list: Array):
		for bullet in bullet_list:
			bullet.connect("damaged_enemy", self, "_on_bullet_damaged_enemy")
	
	func _on_bullet_damaged_enemy(enemy):
		enemy.stun_duration += 0.1

class Clock extends ItemReference:
	
	static func _metadata():
		return {
			"id": 12,
			"charge": -1,
			"rarity": Items.RARITIES.Ultra,
			"item_name": "The Stopwatch",
			"texture": preload("res://Assets/Items/Clock.png"),
			"description": """
			Slows time and grants extra shot rate
			"""
		}
	
	func _init(emitter: Actor):
		Engine.time_scale -= 0.1
		Engine.time_scale = clamp(Engine.time_scale, 0.2, 1.0)
		emitter.max_speed *= 1.1
		emitter.shot_cooldown_multiplier -= 0.1


class PoisionMixture extends ItemReference:
	static func _metadata():
		return {
			"id": 13,
			"charge": -1,
			"rarity": Items.RARITIES.Common,
			"item_name": "Poision Mixture",
			"texture": preload("res://Assets/Items/PoisionMixture.png"),
			"description": """
			Bullets ooze a toxic, metal-eating acid
			"""
		}
	
	func _init(emitter: Actor):
		pass
	
	func _on_shot(bullet_list: Array):
		for bullet in bullet_list:
			bullet.damage += 5
			if bullet.get_node_or_null("Line2D/EmissionParticles"):
				bullet.get_node("Line2D/EmissionParticles").visible = true
				bullet.get_node("Line2D/EmissionParticles").modulate = Color(0.304413, 0.820312, 0.230713)
			bullet.connect("damaged_enemy", self, "_on_bullet_damaged_enemy")
	
	func _on_bullet_damaged_enemy(enemy):
		enemy.apply_status_effect(Globals.STATUS_EFFECTS.PoisionAcid, 5)

class PanicButton extends ItemReference:
	
	static func _metadata():
		return {
			"id": 14,
			"charge": 3,
			"rarity": Items.RARITIES.Common,
			"item_name": "Overdrive",
			"texture": preload("res://Assets/Items/PanicButton.png"),
			"description": """
			In case of an emergency...
			"""
		}
	
	func _init(emitter: Actor):
		pass
	
	func _activated(emitter: Player):
		var ang = 2*PI/9
		var b_list := []
		b_list.resize(9)
		for i in range(9):
			var b: Bullet = emitter.bullet.instance()
			b.damage_multiplier *= 2
			b.rot = ang*i
			b.speed /= 2
			b.position = emitter.position
			b.set_collision_mask_bit(Globals.BIT_ENEMY, true)
			Items.add_child(b)
			b_list[i] = b
		for item in emitter.items:
			item._on_shot(b_list)

class DecelleratingBullets extends ItemReference:
	static func _metadata():
		return {
			"id": 14,
			"charge": -1,
			"rarity": Items.RARITIES.Common,
			"item_name": "Decellerating Bullets",
			"texture": preload("res://Assets/Items/LeadTippedDarts.png"),
			"description": """
			
			"""
		}
	
	func _init(emitter: Actor):
		emitter.shot_cooldown *= 0.8
	
	
	var bullets = []
	func _on_shot(bullet_list: Array):
		
		for bullet in bullet_list:
			bullets.append(bullet)
		
	
	func _process(delta: float) -> void:
		
		for bullet in bullets:
			if is_instance_valid(bullet):
				bullet.speed -= delta * 5

class LaserBullet extends ItemReference:
	var emitter
	
	static func _metadata():
		return {
			"id": 15,
			"charge": -1,
			"rarity": Items.RARITIES.Legendary,
			"item_name": "Laser Coil",
			"texture": preload("res://Assets/Items/LeadTippedDarts.png"),
			"description": """
			
			"""
		}
	
	func _init(_emitter: Actor):
		emitter = _emitter
		emitter.bullet = preload("res://Scenes/Bullets/Laser.tscn")
	
	func _on_shot(bullet_list: Array):
		for laser in bullet_list:
			laser.is_fading_in = false
			laser.get_child(0).set_collision_mask_bit(1, false)
			laser.get_child(0).set_collision_mask_bit(2, true)
		yield(Items.get_tree(), "idle_frame")
		for laser in bullet_list:
			laser.rotation = emitter.get_aim_angle()
			var t := Timer.new()
			laser.add_child(t)
			t.start(0.1)
			t.connect("timeout", self, "on_Laser_timeout", [laser, t])
	
	func on_Laser_timeout(laser, timer):
		laser.delete()
		timer.queue_free()

class Scalar extends ItemReference:
	
	static func _metadata():
		return {
			"id": 16,
			"charge": -1,
			"rarity": Items.RARITIES.Rare,
			"item_name": "Scalar",
			"texture": preload("res://Assets/Items/LeadTippedDarts.png"),
			"description": """
			Bullets deal more damage the more enemies that are on-screen
			"""
		}
	
	func _init(emitter: Actor):
		pass
	
	func _on_shot(bullet_list: Array):
		for bullet in bullet_list:
			var damage_mul: float = clamp(log10(Items.get_tree().get_nodes_in_group("Enemy").size())/2.0 + 1, 1, 2)
			bullet.damage_multiplier *= damage_mul
			bullet.modulate.a += damage_mul - 1
	
	func log10(val: float) -> float:
		return log(val) / log(10)

class Dicannon extends ItemReference:
	var emitter
	var offset := 0.0
	
	static func _metadata():
		return {
			"id": 17,
			"charge": -1,
			"rarity": Items.RARITIES.Rare,
			"item_name": "Scalar",
			"texture": preload("res://Assets/Items/LeadTippedDarts.png"),
			"description": """
			Shoot behind you
			"""
		}
	
	func _init(_emitter: Actor):
		emitter = _emitter
	
	func _init2(_emitter):
		update_offset()
	
	func _on_shot(bullet_list: Array):
		var list = []
		for bullet in bullet_list:
			var bullet2 = bullet.duplicate()
			bullet2.rot = emitter.get_node("Sprite").rotation - PI/2 + offset
			bullet2.set_collision_mask_bit(Globals.BIT_ENEMY, true)
			if not is_zero_approx(offset):
				update_offset()
			Items.add_child(bullet2)
			list.append(bullet2)
		
		for item in emitter.items:
			if item is Dicannon:
				continue
			item._on_shot(list)
	
	func update_offset():
		offset = (randf() - 0.5) * 1.5


class XPAbsorber extends ItemReference:
	var emitter
	
	static func _metadata():
		return {
			"id": 18,
			"charge": -1,
			"rarity": Items.RARITIES.Common,
			"item_name": "XP Absorber",
			"texture": preload("res://Assets/Items/ManaIncrement.png"),
			"description": """
			Gain a slight amount of XP for each hit
			"""
		}
	
	func _init(_emitter: Actor):
		emitter = _emitter
	
	func _on_shot(bullet_list: Array):
		for bullet in bullet_list:
			bullet.connect("damaged_enemy", self, "_on_bullet_damaged_enemy")
	
	func _on_bullet_damaged_enemy(_enemy):
		emitter.xp += 2
		emitter.update_xp()
