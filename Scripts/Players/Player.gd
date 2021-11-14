extends Actor
class_name Player, "res://Assets/Player/Player.png"

var angle: float

const LINE = preload("res://Scenes/Line.tscn")

var max_xp := 100
var xp := 0

var scrap := 0 setget set_scrap

var active_item
var charge := 0
var charge_timer := 0.1

var creating_line := false
var paddle: RigidBody2D
var line: Line2D
var start_pos: Vector2

var shake_amount := 0.0

onready var movement_joystick: TouchScreenButton = $CanvasLayer/MovementJoystick/Ball
onready var aim_joystick: TouchScreenButton = $CanvasLayer/AimJoystick/Ball

onready var long_trail: Line2D = $Trails/LongTrail
onready var burst_inner_trail: Line2D = $Trails/InnerThrust
onready var burst_outer_trail: Line2D = $Trails/OuterThrust

onready var trails := $Trails.get_children()

onready var aim_cursor: Area2D = $Node2/AimCursor

onready var hp_bar: TextureProgress = get_node("CanvasLayer/HPBar")
onready var hp_label: Label = get_node("CanvasLayer/HPBar/HPLabel")

onready var xp_bar: TextureProgress = get_node("CanvasLayer/XPBar")
onready var xp_label: Label = get_node("CanvasLayer/XPBar/XPLabel")

onready var scrap_label: Label = get_node("CanvasLayer/Scrap/ScrapLabel")

onready var ref_rect: ReferenceRect = get_parent().get_node_or_null("ReferenceRect")

var aim_cursor_hovered
enum aim_cursor_methods {
	Mouse,
	Keyboard,
	Joystick
}
var aim_cursor_method: int = aim_cursor_methods.Joystick setget set_aim_cursor

signal level_up(level)
signal picked_scrap(amount)

func _input(event):
	for item in items:
		item._input(event)

func _ready():
	
	aim_cursor.position = position
	$Node2/AimCursor/AnimationPlayer.play("dilate")
	$ShotCooldownTimer.wait_time = shot_cooldown
	$ShotCooldownTimer.start()
	
	max_hp = 200; hp = max_hp
	
	update_xp()
	update_health()
	set_aim_cursor(aim_cursor_method)
	
	$CanvasLayer/ActiveItemRecharge/ActiveItemCharge.wait_time = charge_timer
	$CanvasLayer/ActiveItemRecharge/ActiveItemCharge.start()
	

var camera_shift := Vector2()
func _physics_process(delta: float) -> void:
	
	for scrap in $ScrapPull.get_overlapping_areas():
		scrap.velocity += scrap.to_local(position).normalized()
	
	for item in items:
		item._process(delta)
	
	update_trails()
	
	if Input.is_action_just_pressed("ui_click_right"):
		_on_Active_Button_pressed()
	
	if Input.is_action_just_pressed("ui_accept"):
		get_parent().wave += 1
		get_parent().emit_signal("wave_begun", get_parent().wave)
		
		xp += max((get_parent().enemies_left-2) * 25, 0)
		update_xp()
	
	if Input.is_action_just_pressed("ui_cancel"):
		OS.window_fullscreen = not OS.window_fullscreen
	
	# this is the code for moving the player
	var has_moved := false
	
	velocity += movement_joystick.ball_offset * acceleration / 50
	
	if movement_joystick.ball_offset != Vector2():
		has_moved = false
		velocity = velocity.clamped(max_speed)
	
	if Input.is_action_pressed("ui_left"):
		velocity.x -= acceleration
		has_moved = true
	if Input.is_action_pressed("ui_right"):
		velocity.x += acceleration
		has_moved = true
	if Input.is_action_pressed("ui_down"):
		velocity.y += acceleration
		has_moved = true
	if Input.is_action_pressed("ui_up"):
		velocity.y -= acceleration
		has_moved = true
		
	
	if not has_moved:
		$Sprite/Particles2D3.emitting = false
		velocity = velocity.linear_interpolate(Vector2(), 0.05)
	else:
		$Sprite/Particles2D3.emitting = true
	
	camera_shift = camera_shift.linear_interpolate((aim_cursor.position - position)/4,0.02)
	$Camera2D.offset = camera_shift
	
	if not is_zero_approx(shake_amount):
		
		var randc := Vector2(randf() - 0.5, randf() - 0.5).normalized()
		$Camera2D.offset += randc * clamp(shake_amount * 3, 0.5, 2)
		
		shake_amount -= delta
		
		if is_zero_approx(shake_amount):
			$Camera2D.offset = camera_shift
	
	if Input.is_action_just_pressed("ui_shift"):
		max_speed *= 1.5
		acceleration *= 1.1
	elif Input.is_action_just_released("ui_shift"):
		max_speed /= 1.5
		acceleration /= 1.1
	
	
	velocity = velocity.clamped(max_speed)
	
	angle = lerp_angle(angle, velocity.angle(), 0.2)
	
	rotation = angle + PI/2
	$CollisionShape2D.rotation = angle + PI/2
	
	move_and_slide(velocity)

func _process(delta: float) -> void:
	
	if is_instance_valid(aim_cursor_hovered):
		aim_cursor.position = aim_cursor_hovered.position
	
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
		
		if ref_rect:
			var rect := ref_rect.get_global_rect().grow(20)
			if rect.has_point(aim_cursor.position + aim_cursor_vel):
				aim_cursor.position += aim_cursor_vel
	
	# else, use the mouse to move the aim cursor
	elif aim_cursor_method == aim_cursor_methods.Mouse:
		aim_cursor.position = get_global_mouse_position()
	
	elif aim_cursor_method == aim_cursor_methods.Joystick:
		var aim_cursor_vel: Vector2 = aim_joystick.ball_offset 
		
		if ref_rect:
			var rect := ref_rect.get_global_rect().grow(20)
			if rect.has_point(aim_cursor.position + aim_cursor_vel):
				if not aim_cursor_vel.is_equal_approx(Vector2.ZERO):
					aim_cursor.position += aim_cursor_vel * delta * 7
					aim_cursor_hovered = null

func update_trails():
	for trail in trails:
		trail.add_point(position+Vector2(0, 5).rotated(rotation))
		
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

# called automatically by a timer
func shoot():
	
	$ShootSFX.play()
	
	#shoot actuall returns an array of all shots done this frame (in case you have multiple shots)
	var b_list: Array = .shoot()
	
	var i := 0
	
	for bullet in b_list:
		
		#this is the current offset from the leftmostpoint of shot_fan_range
		var addon := i*shot_fan_range/b_list.size() - shot_fan_range/4
		if b_list.size() == 1:
			bullet.rot = get_aim_angle()
		else:
			bullet.rot = get_aim_angle() + addon
		
		# set it to hit enemies, not the player itself
		bullet.set_collision_mask_bit(Globals.BIT_ENEMY, true)
		get_parent().add_child(bullet)
		i += 1
	
	return b_list

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
		get_parent().add_child(paddle)
	
	# should be the on released
	if Input.is_action_just_released(key):
		creating_line = false
		paddle.set_collision_mask_bit(1, true)
	
	# if it is creating lines,
	if creating_line:
		line.remove_point(0)
		line.remove_point(1)
		
		var to_center: Vector2 = (global_position-start_pos)/2
		
		# local coordinates are used. Sets lines at player and at init pos
		line.add_point(-to_center)
		line.add_point(to_center)
		
		# set the paddles position at all times to be at the center of the init spawn and player
		paddle.position = global_position - to_center
		paddle.get_node("CollisionShape2D").shape.extents.x = to_center.length()
		paddle.get_node("CollisionShape2D").rotation = to_center.angle()
		paddle.get_node("Area2D/CollisionShape2D").shape.extents.x = to_center.length() + 0.5
		paddle.get_node("Area2D/CollisionShape2D").rotation = to_center.angle()


func get_aim_angle() -> float:
	return (aim_cursor.position - position).angle()


func take_damage(damage: int):
	
	if immune_time > 0.0:
		return
	
	.take_damage(damage)
	hp -= damage
	hp = clamp(hp, 0, max_hp)
	update_health()
	
	if damage > 0:
		shake_amount += 1
	$AnimationPlayer.play("RGBOffset")
	
	if hp <= 0:
		die()

func update_health(flash := true):
	var tween: Tween = hp_bar.get_node("Tween")
	tween.interpolate_property(hp_bar, "value", hp_bar.value, (hp*100)/max_hp, 0.3, Tween.TRANS_LINEAR)
	tween.start()
	
	if flash:
		hp_bar.get_node("AnimationPlayer").play("Flash")
	
	hp_bar.rect_size.x = max_hp
	hp_label.text = str(hp) + "/" + str(max_hp)

const SAVE_FILE = "user://leaderboards.save"
func die():
	get_tree().paused = true
	
	show_leaderboard()
	Input.set_custom_mouse_cursor(null)

func show_leaderboard():
	$CanvasLayer/Leaderboard.visible = true
	
	var f: File = File.new()
	if f.file_exists(SAVE_FILE):
		f.open(SAVE_FILE, File.READ_WRITE)
		var waves := [get_parent().wave]
		
		var wave = f.get_16()
		var iters = 0
		while wave != 0:
			waves.append(wave)
			wave = f.get_16()
		
		waves.sort()
		waves.invert()
		
		# only says "<-- CURRENT" once
		var has_currented := false
		for f_wave in waves:
			var print_str: String = "Wave " + str(f_wave)
			
			if get_parent().wave == f_wave and not has_currented:
				print_str += " <-- CURRENT"
				has_currented = true
			
			$CanvasLayer/Leaderboard/ItemList.add_item(print_str)
		f.store_16(get_parent().wave)
	else:
		f.open(SAVE_FILE, File.WRITE_READ)
		$CanvasLayer/Leaderboard/ItemList.add_item("Wave "+str(get_parent().wave))
		f.store_16(get_parent().wave)
	f.close()

var level = 0
func update_xp(flash := true):
	
	while xp > max_xp:
		xp -= max_xp
		max_xp += 10
		level += 1
		emit_signal("level_up", level)
	
	var tween: Tween = xp_bar.get_node("Tween")
	tween.interpolate_property(xp_bar, "value", xp_bar.value, (xp*100)/max_xp, 0.3, Tween.TRANS_LINEAR)
	tween.start()
	
	if flash:
		xp_bar.get_node("AnimationPlayer").play("Flash")
	
	xp_bar.rect_size.x = max_xp * 1.7
	xp_label.text = str(xp) + "/" + str(max_xp)

func on_level_up(level):
	max_hp += randi() % 6 + 3
	update_health()


func set_scrap(val: int):
	scrap = val
	scrap_label.text = str(scrap)

func _on_AimCursor_body_entered(body):
	if aim_cursor_hovered == null:
		aim_cursor_hovered = body

func on_Enemy_dead(enemy: KinematicBody2D):
	shake_amount += 0.5
	if enemy == aim_cursor_hovered:
		aim_cursor_hovered = get_closest_enemy_from_aim_cursor(enemy)

func set_aim_cursor(val: int):
	match val:
		aim_cursor_methods.Mouse:
			Input.set_custom_mouse_cursor(preload("res://Assets/Transparent.png"))
		_:
			Input.set_custom_mouse_cursor(null)
	aim_cursor_method = val

func set_shot_cooldown(val):
	shot_cooldown = val
	$ShotCooldownTimer.wait_time = clamp(val * shot_cooldown_multiplier, 0.05, 3)
func set_shot_cooldown_multiplier(val):
	shot_cooldown_multiplier = val
	$ShotCooldownTimer.wait_time = clamp(val * shot_cooldown, 0.05, 3)


func _on_ActiveItemCharge_timeout():
	if charge == 101: return
	charge += 1
	$CanvasLayer/ActiveItemRecharge.value = charge
	if charge == 100:
		charge = 101
		$CanvasLayer/ActiveItemButton/AnimationPlayer.play("FlashActive")
		$CanvasLayer/ActiveItemButton.texture = preload("res://Assets/TheButton.png")

func _on_Active_Button_pressed():
	if charge == 101 and active_item:
		active_item._activated(self)
		charge = 0
		$CanvasLayer/ActiveItemButton.texture = preload("res://Assets/TheButton-Darkened.png")


func add_item(item):
	.add_item(item)
	
	var metadata: Dictionary = item._metadata()
	var charge: int = metadata.charge
	if charge != -1:
		$CanvasLayer/ActiveItemRecharge/Sprite.texture = metadata.texture
		active_item = item.new(self)
		charge_timer = charge/60.0
		$CanvasLayer/ActiveItemRecharge/ActiveItemCharge.wait_time = charge_timer
		$CanvasLayer/ActiveItemRecharge/ActiveItemCharge.start()
	
	else:
		$CanvasLayer/ItemList.add_item("", metadata.texture, false)


func _on_Restart_button_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/MainMenu.tscn")


func _on_Resume_button_pressed():
	get_tree().paused = false
	$CanvasLayer/PauseMenu.hide()

func _on_Pause_button_released():
	get_tree().paused = not get_tree().paused
	$CanvasLayer/PauseMenu.visible = not $CanvasLayer/PauseMenu.visible

