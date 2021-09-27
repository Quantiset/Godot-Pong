extends Node




class ItemReference extends Resource:
	var max_hp_increase := 0
	var hp_increase := 0
	var damage_increase := 0
	var pierce_increase := 0
	
	var texture := preload("res://Assets/Ball.png")
	var description := "Description not added yet"
	var item_name := "Item"

class LeadTippedDarts extends ItemReference:
	func _init():
		damage_increase = 10
		pierce_increase = 1
		
		item_name = "Lead Tipped Darts"
		texture = preload("res://Assets/Items/LeadTippedDarts.png")
		description = """
		+10 Damage \n
		+1 Pierce
		"""

