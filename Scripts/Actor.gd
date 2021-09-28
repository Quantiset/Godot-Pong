extends KinematicBody2D
class_name Actor

var velocity := Vector2()

export var max_hp := 100
var hp := max_hp

var bullet = preload("res://Scenes/Bullets/StraightBullet.tscn")
export var shot_damage := 25
export var shot_pierces := 0
export var aim_speed := 300
export var shot_speed := 10
export var shot_cooldown := 0.5

export var trail_length := 100
export var thrust_length := 6

export var max_speed := 300
export var acceleration := 20

var items := []

func add_item(item):
	if item is GDScript:
		item = item.new()
	
	parse_item_oddities(item)
	
	items.append(item)
	max_hp += item.max_hp_increase
	max_hp *= item.max_hp_multiplier_increase
	max_hp = clamp(max_hp, 1, 450)
	hp += item.hp_increase
	hp *= item.hp_multiplier_increase
	hp = int(clamp(hp, 0, max_hp))
	if has_method("update_health"):
		call("update_health")
	
	shot_damage += item.damage_increase
	shot_pierces += item.pierce_increase
	
	shot_speed += item.shot_speed_increase
	shot_speed = clamp(shot_speed, 1, 30)
	
	max_speed += item.speed_increase
	max_speed = clamp(max_speed, 50, 600)
	
	shot_cooldown += item.shot_cooldown_increase
	shot_cooldown = clamp(shot_cooldown, 0.1, 5)
	
	if item.override_bullet:
		bullet = item.override_bullet

func has_item(item):
	if item is GDScript:
		item = item.new()
	
	return items.has(item)

func parse_item_oddities(item):
	if item is Items.HeatseekingMissiles:
		pass
