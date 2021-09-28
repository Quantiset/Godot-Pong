extends Node

class ItemReference extends Resource:
	var max_hp_increase := 0
	var max_hp_multiplier_increase := 1.0
	var hp_increase := 0
	var hp_multiplier_increase := 1.0
	
	var speed_increase := 0
	
	var damage_increase := 0
	var pierce_increase := 0
	
	var override_bullet = false
	
	var shot_speed_increase := 0
	var shot_cooldown_increase := 0
	
	var item_name := "Item"
	var texture := preload("res://Assets/Ball.png")
	var description := "Description not added yet"

class LeadTippedDarts extends ItemReference:
	func _init():
		damage_increase = +10
		pierce_increase = +1
		
		item_name = "Lead Tipped Darts"
		texture = preload("res://Assets/Items/LeadTippedDarts.png")
		description = """
		+10 Damage \n
		+1 Pierce
		"""

class HeatseekingMissiles extends ItemReference:
	func _init():
		damage_increase = +15
		shot_speed_increase = -6
		shot_cooldown_increase = +0.4
		
		override_bullet = preload("res://Scenes/Bullets/HeatseekingBullet.tscn")
		
		item_name = "Heatseeking Missiles"
		texture = preload("res://Assets/Items/HeatseekingMissiles.png")
		description = """
		
		"""

class RefinedPlating extends ItemReference:
	func _init():
		max_hp_increase = +50
		max_hp_multiplier_increase = +1.2
		hp_increase = +50
		hp_multiplier_increase = +1.2
		speed_increase = +100
		
		item_name = "Refined Plating"
		texture = preload("res://Assets/Items/RefinedPlating.png")
		description = """
		
		"""
