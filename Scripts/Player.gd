extends KinematicBody2D

var velocity := Vector2()

export var max_speed := 300
export var acceleration := 20

const LINE = preload("res://Scenes/Line.tscn")
var line: Line2D

var creating_line := false

func _physics_process(delta: float) -> void:
	
	for col_idx in range(get_slide_count()):
		var collision : KinematicCollision2D = get_slide_collision(col_idx)
		print(velocity, collision.normal)
		velocity = velocity.bounce(collision.normal)
	
	var has_moved := false
	if Input.is_action_pressed("ui_up"):
		velocity.y -= acceleration
		has_moved = true
	if Input.is_action_pressed("ui_down"):
		velocity.y += acceleration
		has_moved = true
	if Input.is_action_pressed("ui_left"):
		velocity.x -= acceleration
		has_moved = true
	if Input.is_action_pressed("ui_right"):
		velocity.x += acceleration
		has_moved = true
	if not has_moved:
		velocity = velocity.linear_interpolate(Vector2(), 0.05)
	
	if Input.is_action_just_pressed("ui_accept"):
		creating_line = true
		var l = LINE.instance()
		get_node("/root").add_child(l)
		line = l.get_node("Line2D")
		line.add_point(global_position*2)
		line.add_point(global_position*2)
	if Input.is_action_just_released("ui_accept"):
		creating_line = false
	
	if creating_line:
		line.remove_point(1)
		line.add_point(global_position*2)
	
	velocity = velocity.clamped(max_speed)
	
	
	move_and_slide(velocity)
