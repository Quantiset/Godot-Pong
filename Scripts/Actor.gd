extends KinematicBody2D
class_name Actor

var velocity := Vector2()

export var max_hp := 100 
var hp := max_hp

var bullet = preload("res://Scenes/Bullets/StraightBullet.tscn")
export var shot_amount    := 1
export var shot_fan_range := PI/4
export var aim_speed      := 300
export var shot_cooldown  := 0.5
export var shot_modulate  := Color("ffffff")

export var trail_length := 100
export var thrust_length := 6

export var max_speed := 300 setget set_max_speed
export var acceleration := 20

var items := []

func set_max_speed(val):
	if is_in_group("Player"):
		breakpoint

func add_item(item):
	
	if item is GDScript:
		item = item.new(self)
	
	
	if has_method("update_health"):
		call("update_health")
	
	if has_item(item):
		item._nonfirst(self)
	
	items.append(item)

func has_item(item) -> bool:
	for held_item in items:
		if held_item.id() == item.id():
			return true
	return false

func shoot():
	var b_list = []
	
	for i in range(shot_amount):
		var b_inst: Bullet = bullet.instance()
		b_inst.position = position
		b_list.append(b_inst)
	
	for item in items:
		item._on_shot(b_list)
	
	return b_list

