extends KinematicBody2D

export (int) var max_hp := 100
var hp := max_hp

export (int) var speed := 100
export (int) var trail_length = 100

export (int) var thrust_length = 20

export (int) var shoot_rate = 500

export (int) var fog_amount := 400

var angle := -PI/2
var velocity := Vector2()

onready var player: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]

onready var trails := $Node.get_children()


func _ready():
	$Sprite/SmokeTrail.amount = fog_amount
	$Sprite/SmokeTrail.emitting = true

func _physics_process(delta: float) -> void:
	var to_player := to_local(player.position)
	
	if to_player.length() > 100:
		velocity = to_local(player.position).normalized() * speed
		$Sprite/SmokeTrail.emitting = true
	else:
		velocity = velocity.linear_interpolate(Vector2(), 0.02)
		$Sprite/SmokeTrail.emitting = false
	
	angle = lerp_angle(angle, velocity.angle(), 0.2)
	
	$Sprite.rotation = angle + PI/2
	$CollisionShape2D.rotation = angle+ PI/2
	
	if randi() % shoot_rate == 1:
		var b = preload("res://Scenes/StraightBullet.tscn")
		var b_inst = b.instance()
		b_inst.position = position
		b_inst.rot = velocity.angle()
		b_inst.speed = 10
		b_inst.get_node("CollisionShape2D/RayCast2D").add_exception(self)
		b_inst.set_collision_mask_bit(1, true)
		get_parent().add_child(b_inst)
	
	move_and_slide(velocity, Vector2())
	
	for trail in trails:
		trail.add_point(position+Vector2(0, 10).rotated($Sprite.rotation))
		
		var max_points = trail_length if trail == $Node/LongTrail else thrust_length
		
		if trail.get_point_count() > max_points:
			trail.remove_point(0)


func take_damage(damage: int) -> void:
	hp -= damage
	if hp <= 0 and not is_queued_for_deletion():
		$ExplosionParticles.emitting = true
		Globals.remove_particle(self, $ExplosionParticles, false)
		Globals.remove_particle(self, $Sprite/SmokeTrail, true)
		set_physics_process(false)
		queue_free()
