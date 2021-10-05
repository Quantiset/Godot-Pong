extends Actor
class_name Enemy


export (int) var shoot_rate = 500
export (int) var fog_amount := 10

onready var player: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]

onready var trails := $Trails.get_children()

const HPDROP = preload("res://Scenes/HealthDrop.tscn")
const ITEM = preload("res://Scenes/Item.tscn")

var hp_drop_rate = 10
var item_drop_rate = 20

signal dead()

func _ready():
	max_speed = 150
	
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
	
	if randi() % hp_drop_rate == 0 and get_tree().get_nodes_in_group("HealthDrop").size() <= 3:
		var hp = HPDROP.instance()
		hp.position = position
		get_parent().call_deferred("add_child", hp)
	elif randi() % item_drop_rate == 0:
		var i = ITEM.instance()
		i.position = position
		i.type = Globals.parse_pool(Globals.ITEM_POOL)
		get_parent().call_deferred("add_child", i)
	
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
	queue_free()
	emit_signal("dead")


func _on_VisibilityNotifier2D_screen_exited():
	pass
