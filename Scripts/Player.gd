extends Actor
class_name Player

var angle: float

const LINE = preload("res://Scenes/Line.tscn")

var max_xp := 100
var xp := 0

var creating_line := false
var paddle: RigidBody2D
var line: Line2D
var start_pos: Vector2

onready var long_trail: Line2D = $Node/LongTrail
onready var burst_inner_trail: Line2D = $Node/InnerThrust
onready var burst_outer_trail: Line2D = $Node/OuterThrust

onready var trails := $Node.get_children()

onready var aim_cursor: Area2D = $Node2/AimCursor

onready var hp_bar: TextureProgress = get_node("CanvasLayer/HPBar")
onready var hp_label: Label = get_node("CanvasLayer/HPBar/HPLabel")

onready var xp_bar: TextureProgress = get_node("CanvasLayer/XPBar")
onready var xp_label: Label = get_node("CanvasLayer/XPBar/XPLabel")

var aim_cursor_hovered
enum aim_cursor_methods {
	Mouse,
	Keyboard
}
var aim_cursor_method: int = aim_cursor_methods.Keyboard setget set_aim_cursor

func _ready():
	
	
	Globals.spawn_item_at(Items.DoubledMuzzle, Vector2(100,100))
	
	#set_aim_cursor(aim_cursor_methods.Mouse)
	aim_cursor.position = position
	$Node2/AimCursor/AnimationPlayer.play("dilate")
	$ShotCooldownTimer.wait_time = shot_cooldown
	$ShotCooldownTimer.start()
	update_xp()

func _physics_process(delta: float) -> void:
	
	if is_instance_valid(aim_cursor_hovered):
		aim_cursor.position = aim_cursor_hovered.position
	
	update_trails()
	
	if Input.is_action_just_pressed("ui_cancel"):
		OS.window_fullscreen = not OS.window_fullscreen
	
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
	
	# this is for moving the aim cursor if keyboard is selected to move it
	if aim_cursor_method == aim_cursor_methods.Keyboard:
		var aim_cursor_vel := Vector2()
		if Input.is_action_pressed("focus_up"):
			aim_cursor_vel.y -= aim_speed * delta
			aim_cursor_hovered = null
		if Input.is_action_pressed("focus_down"):
			aim_cursor_vel.y += aim_speed * delta
			aim_cursor_hovered = null
		if Input.is_action_pressed("focus_left"):
			aim_cursor_vel.x -= aim_speed * delta
			aim_cursor_hovered = null
		if Input.is_action_pressed("focus_right"): 
			aim_cursor_vel.x += aim_speed * delta
			aim_cursor_hovered = null
		
		var ref_rect: ReferenceRect = get_parent().get_node_or_null("ReferenceRect")
		if ref_rect:
			if ref_rect.get_global_rect().has_point(aim_cursor.position + aim_cursor_vel):
				aim_cursor.position += aim_cursor_vel
	
	# else, use the mouse to move the aim cursor
	elif aim_cursor_method == aim_cursor_methods.Mouse:
		aim_cursor.position = get_global_mouse_position()
	
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
	#shoot actuall returns an array of all shots done this frame (in case you have multiple shots)
	var b_: Array = .shoot()
	
	var i := 0
	
	for b in b_:
		
		#this is the current offset from the leftmostpoint of shot_fan_range
		var addon := i*shot_fan_range/b_.size() - shot_fan_range/4
		if b_.size() == 1:
			b.rot = to_local(aim_cursor.position).angle()
		else:
			b.rot = to_local(aim_cursor.position).angle() + addon
		
		# set it to hit enemies, not the player itself
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
	var tween: Tween = hp_bar.get_node("Tween")
	tween.interpolate_property(hp_bar, "value", hp_bar.value, (hp*100)/max_hp, 0.3, Tween.TRANS_LINEAR)
	tween.start()
	
	hp_bar.get_node("AnimationPlayer").play("Flash")
	
	hp_bar.rect_size.x = max_hp*2
	hp_label.text = str(hp) + "/" + str(max_hp)

func update_xp():
	
	if xp > max_xp:
		xp = 0
		max_xp += 10
		print("level up!")
	
	var tween: Tween = xp_bar.get_node("Tween")
	tween.interpolate_property(xp_bar, "value", xp_bar.value, (xp*100)/max_xp, 0.3, Tween.TRANS_LINEAR)
	tween.start()
	
	xp_bar.get_node("AnimationPlayer").play("Flash")
	
	xp_bar.rect_size.x = max_xp * 1.7
	xp_label.text = str(xp) + "/" + str(max_xp)

func _on_AimCursor_body_entered(body):
	if aim_cursor_hovered == null:
		aim_cursor_hovered = body

func on_Enemy_dead(enemy: KinematicBody2D):
	if enemy == aim_cursor_hovered:
		aim_cursor_hovered = get_closest_enemy_from_aim_cursor(enemy)

func set_aim_cursor(val: int):
	match val:
		aim_cursor_methods.Mouse:
			Input.set_custom_mouse_cursor(preload("res://Assets/Transparent.png"))
		_:
			Input.set_custom_mouse_cursor(null)
	aim_cursor_method = val
