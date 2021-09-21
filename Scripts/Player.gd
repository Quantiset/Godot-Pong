extends KinematicBody2D

var velocity := Vector2()

export var trail_length := 100

export var thrust_length := 6

export var max_speed := 300
export var acceleration := 20

const LINE = preload("res://Scenes/Line.tscn")

var creating_line := false
var paddle: RigidBody2D
var line: Line2D
var start_pos: Vector2

onready var long_trail : Line2D = $Node/LongTrail
onready var burst_inner_trail : Line2D = $Node/InnerThrust
onready var burst_outer_trail : Line2D = $Node/OuterThrust

onready var trails := [
	long_trail, burst_inner_trail, burst_outer_trail
]



func _physics_process(delta: float) -> void:
	
	for trail in trails:
		trail.add_point(position+Vector2(0, 10).rotated($Sprite.rotation))
		
		var max_points = trail_length if trail == long_trail else thrust_length
		
		if trail.get_point_count() > max_points:
			trail.remove_point(0)
	
	
	for col_idx in range(get_slide_count()):
		var collision : KinematicCollision2D = get_slide_collision(col_idx)
		
#		if collision.collider.is_in_group("Moveables"):
#			collision.collider.add_impulse(to_local(collision.collider.global_position).normalized()*100)
#
		velocity = velocity.bounce(collision.normal)
		velocity *= 0.7
	
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
	
	if Input.is_action_just_pressed("ui_shift"):
		max_speed *= 1.5
		acceleration *= 1.5
	elif Input.is_action_just_released("ui_shift"):
		max_speed /= 1.5
		acceleration /= 1.5
	
	if Input.is_action_just_pressed("ui_accept"):
		creating_line = true
		paddle = LINE.instance()
		paddle.get_node("CollisionShape2D").shape = paddle.get_node("CollisionShape2D").shape.duplicate()
		paddle.get_node("Area2D/CollisionShape2D").shape = paddle.get_node("Area2D/CollisionShape2D").shape.duplicate()
		get_node("/root").add_child(paddle)
		line = paddle.get_node("Line2D")
		line.add_point(Vector2())
		line.add_point(Vector2())
		start_pos = global_position
	if Input.is_action_just_released("ui_accept"):
		creating_line = false
		paddle.set_collision_mask_bit(1, true)
	
	if creating_line:
		line.remove_point(0)
		line.remove_point(1)
		
		var to_center := (global_position-start_pos)/2
		
		line.add_point(-to_center)
		line.add_point(to_center)
		
		paddle.position = global_position-to_center
		paddle.get_node("CollisionShape2D").shape.extents.x = to_center.length()
		paddle.get_node("CollisionShape2D").rotation = to_center.angle()
		paddle.get_node("Area2D/CollisionShape2D").shape.extents.x = to_center.length()+0.5
		paddle.get_node("Area2D/CollisionShape2D").rotation = to_center.angle()
	
	velocity = velocity.clamped(max_speed)
	
	$Sprite.rotation = velocity.angle() + PI/2
	$CollisionShape2D.rotation = velocity.angle() + PI/2
	
	move_and_slide(velocity, Vector2(), false, 4, 0.78, true)
