extends Actor
class_name Player

var angle: float

const LINE = preload("res://Scenes/Line.tscn")

var creating_line := false
var paddle: RigidBody2D
var line: Line2D
var start_pos: Vector2

onready var long_trail: Line2D = $Node/LongTrail
onready var burst_inner_trail: Line2D = $Node/InnerThrust
onready var burst_outer_trail: Line2D = $Node/OuterThrust

onready var trails := $Node.get_children()

onready var aim_cursor: Area2D = $Node2/AimCursor

onready var hp_bar := get_node("/root/Main/HPBar")


var enemy_cursor_hovered

func _ready():
	
	aim_cursor.position = position
	$Node2/AimCursor/AnimationPlayer.play("dilate")
	$ShotCooldownTimer.wait_time = shot_cooldown
	$ShotCooldownTimer.start()

func _physics_process(delta: float) -> void:
	
	if is_instance_valid(enemy_cursor_hovered):
		aim_cursor.position = enemy_cursor_hovered.position
	
	update_trails()
	
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
		$Sprite/Particles2D3.emitting = false
		velocity = velocity.linear_interpolate(Vector2(), 0.05)
	else:
		$Sprite/Particles2D3.emitting = true
	
	if Input.is_action_pressed("focus_up"):
		aim_cursor.position.y -= aim_speed * delta
		enemy_cursor_hovered = null
	if Input.is_action_pressed("focus_down"):
		aim_cursor.position.y += aim_speed * delta
		enemy_cursor_hovered = null
	if Input.is_action_pressed("focus_left"):
		aim_cursor.position.x -= aim_speed * delta
		enemy_cursor_hovered = null
	if Input.is_action_pressed("focus_right"): 
		aim_cursor.position.x += aim_speed * delta
		enemy_cursor_hovered = null
	
	if Input.is_action_just_pressed("ui_shift"):
		max_speed *= 1.5
		acceleration *= 1.1
	elif Input.is_action_just_released("ui_shift"):
		max_speed /= 1.5
		acceleration /= 1.1
	
	
	velocity = velocity.clamped(max_speed)
	
	angle = lerp_angle(angle, velocity.angle(), 0.2)
	
	$Sprite.rotation = angle + PI/2
	$CollisionShape2D.rotation = angle+ PI/2
	
	move_and_slide(velocity)

func update_trails():
	for trail in trails:
		trail.add_point(position+Vector2(0, 10).rotated($Sprite.rotation))
		
		var max_points = trail_length if trail == long_trail else thrust_length
		
		if trail.get_point_count() > max_points:
			trail.remove_point(0)

func get_closest_enemy_from_aim_cursor(exception = null):
	var enemies = get_tree().get_nodes_in_group("Enemy")
	
	enemies.erase(exception)
	if enemies.size() == 0:
		return null
	
	var closest_enemy = enemies[0]
	for enemy in enemies:
		if aim_cursor.to_local(enemy.position).length() < \
		aim_cursor.to_local(closest_enemy.position).length():
			closest_enemy = enemy
	
	return closest_enemy

func shoot():
	var b_: Array = .shoot()
	
	var i := 0
	
	for b in b_:
		var addon := i*shot_fan_range/b_.size() - shot_fan_range/4
		if b_.size() == 1:
			b.rot = to_local(aim_cursor.position).angle()
		else:
			b.rot = to_local(aim_cursor.position).angle() + addon
		b.set_collision_mask_bit(Globals.BIT_ENEMY, true)
		get_parent().add_child(b)
		i += 1

func create_pong_paddles(key: String):
	# rebind false to a key to create pong trails
	if Input.is_action_just_pressed(key):
		creating_line = true
		paddle = LINE.instance()
		paddle.get_node("CollisionShape2D").shape = paddle.get_node("CollisionShape2D").shape.duplicate()
		paddle.get_node("Area2D/CollisionShape2D").shape = paddle.get_node("Area2D/CollisionShape2D").shape.duplicate()
		line = paddle.get_node("Line2D")
		line.add_point(Vector2())
		line.add_point(Vector2())
		start_pos = global_position
		get_node("/root").add_child(paddle)
	
	# should be the on released
	if Input.is_action_just_released(key):
		creating_line = false
		paddle.set_collision_mask_bit(1, true)
	
	if creating_line:
		line.remove_point(0)
		line.remove_point(1)
		
		var to_center: Vector2 = (global_position-start_pos)/2
		
		line.add_point(-to_center)
		line.add_point(to_center)
		
		paddle.position = global_position - to_center
		paddle.get_node("CollisionShape2D").shape.extents.x = to_center.length()
		paddle.get_node("CollisionShape2D").rotation = to_center.angle()
		paddle.get_node("Area2D/CollisionShape2D").shape.extents.x = to_center.length() + 0.5
		paddle.get_node("Area2D/CollisionShape2D").rotation = to_center.angle()

func take_damage(damage: int):
	hp -= damage
	hp = clamp(hp, 0, max_hp)
	update_health()
	if hp <= 0:
		get_tree().reload_current_scene()

func update_health():
	hp_bar.value = (hp*100)/max_hp
	hp_bar.rect_size.x = max_hp*2
	get_node("/root/Main/HPLabel").text = str(hp) + "/" + str(max_hp)

func _on_AimCursor_body_entered(body):
	if enemy_cursor_hovered == null:
		enemy_cursor_hovered = body

func on_Enemy_dead(enemy: KinematicBody2D):
	if enemy == enemy_cursor_hovered:
		enemy_cursor_hovered = get_closest_enemy_from_aim_cursor(enemy)

