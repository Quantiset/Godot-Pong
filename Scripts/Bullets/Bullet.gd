extends Area2D
class_name Bullet


onready var normal_detector: RayCast2D = $NormalDetector

var velocity := Vector2()

var rot: float
var speed := 10.0 setget set_speed

var damage := 25 setget set_damage
var damage_multiplier := 1.0 setget set_damage_multiplier

var pierces := 0
var bounces := 0

var is_visible := true

signal hit_object(object)
signal damaged_enemy(enemy)

func _ready():
	if get_node_or_null("NormalDetector"):
		$NormalDetector.collision_mask = collision_mask

func _on_Bullet_body_entered(body):
	collide(body)

func collide(body):
	
	emit_signal("hit_object", body)
	if body.has_method("take_damage"):
		emit_signal("damaged_enemy", body)
		body.take_damage(get_total_damage())
		if pierces > 0:
			pierces -= 1
			return
	
	if body is RigidBody2D:
		body.apply_central_impulse(velocity.normalized() * 20)
	
	if bounces > 0:
		bounce()
		bounces -= 1
		return
	
	if body.is_in_group("Player") and body.has_item(Items.RefinedPlating):
		bounce()
		set_collision_mask_bit(Globals.BIT_PLAYER, false)
		set_collision_mask_bit(Globals.BIT_ENEMY, true)
		return
	
	delete()

func bounce():
	var n := get_normal()
	if n:
		velocity = velocity.bounce(n)
		rot = velocity.angle()

func get_normal() -> Vector2:
	var normal := Vector2()
	
	if not normal_detector:
		delete()
		return Vector2() 
	
	normal_detector.global_rotation = 0
	
	normal_detector.cast_to = velocity * 4
	normal_detector.force_raycast_update()
	if normal_detector.is_colliding():
		normal = normal_detector.get_collision_normal()
	
	if normal == Vector2():
		delete()
		return Vector2()
	
	return normal

func delete():
	
	if is_queued_for_deletion():
		return
	
	$Particles2D.emitting = false
	Globals.remove_particle($Particles2D)
	
	$ExplosionParticles2.modulate = modulate
	$ExplosionParticles2.emitting = true
	Globals.remove_particle($ExplosionParticles2)
	
	if is_visible:
		$ExplosionParticles.modulate = modulate
		$ExplosionParticles.emitting = true
		Globals.remove_particle($ExplosionParticles)
	
	queue_free()


func set_damage_multiplier(val) -> void:
	damage_multiplier = val
	damage_multiplier = clamp(damage_multiplier, 0.1, 999)

func set_damage(val) -> void:
	damage = val
	damage = clamp(damage, 5, 100)

func set_speed(val) -> void:
	speed = val
	speed = clamp(speed, 3.0, 30.0)

func get_total_damage() -> int:
	return int(damage*damage_multiplier)


func _on_VisibilityNotifier2D_screen_entered():
	is_visible = true

func _on_VisibilityNotifier2D_screen_exited():
	is_visible = false
