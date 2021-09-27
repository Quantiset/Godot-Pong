extends KinematicBody2D
class_name Enemy

export (int) var max_hp := 100
var hp := max_hp

export (float) var acceleration := 5.0
export (int) var max_speed := 150
export (int) var trail_length = 100

export (int) var thrust_length = 20

export (int) var shoot_rate = 500

export (int) var fog_amount := 10

var velocity := Vector2()

onready var player: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]

onready var trails := $Trails.get_children()

signal dead()

func _ready():
	$Sprite/SmokeTrail.amount = fog_amount
	$Sprite/SmokeTrail.emitting = true

func _physics_process(delta: float) -> void:
	
	for trail in trails:
		trail.add_point(position+Vector2(0, 10).rotated($Sprite.rotation))
		
		var max_points = trail_length if trail == $Trails/LongTrail else thrust_length
		
		if trail.get_point_count() > max_points:
			trail.remove_point(0)


func take_damage(damage: int) -> void:
	hp -= damage
	$AnimationPlayer.play("Flash")
	if hp <= 0 and not is_queued_for_deletion():
		die()

func die():
	#Globals.remove_trail($Node/LongTrail)
	$ExplosionParticles.emitting = true
	$Sprite/SmokeTrail.emitting = false
	$ExplosionParticlesFire.emitting = true
	$ExplosionParticlesRed.emitting = true
	Globals.remove_particle($ExplosionParticles)
	Globals.remove_particle($Sprite/SmokeTrail)
	Globals.remove_particle($ExplosionParticlesFire)
	Globals.remove_particle($ExplosionParticlesRed)
	set_physics_process(false)
	emit_signal("dead")
	queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	# if an enemy somehow leaves the screen, this prevents it from blockading the game
	if not is_queued_for_deletion():
		die()
