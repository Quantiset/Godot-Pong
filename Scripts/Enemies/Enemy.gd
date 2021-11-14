extends Actor
class_name Enemy


export (int) var shoot_rate = 500
export (int) var fog_amount := 10

onready var player: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]

onready var trails := $Trails.get_children()

const HPDROP = preload("res://Scenes/HealthDrop.tscn")
const ITEM = preload("res://Scenes/Item.tscn")

var speed_core_multiplier := 1.0

var is_visible := false

signal dead()
signal boosted()

func _ready():
	max_speed /= 2
	
	$Sprite/SmokeTrail.amount = fog_amount
	$Sprite/SmokeTrail.emitting = true

func _physics_process(delta: float) -> void:
	
	for trail in trails:
		trail.add_point(position+Vector2(0, 10).rotated(rotation))
		
		var max_points = trail_length if trail == $Trails/LongTrail else thrust_length
		
		if trail.get_point_count() > max_points:
			trail.remove_point(0)
	
	move_and_slide(velocity*speed_core_multiplier, Vector2())

func take_damage(damage: int) -> void:
	.take_damage(damage)
	hp -= damage
	$AnimationPlayer.play("Flash")
	if hp <= 0 and not is_queued_for_deletion():
		die()
	if damage > 0:
		stun()

func die():
	
	for i in range(randi()%4):
		var it = ITEM.instance()
		it.position = position + Vector2(randf()-0.5, randf()-0.5)*30
		it.scale /= 1.5
		it.type = Items.BlueScrap if randi() % 4 == 0 else Items.Scrap
		#it.type = Globals.parse_pool(Globals.ITEM_POOL)
		get_parent().call_deferred("add_child", it)
	
	#Globals.remove_trail($Node/LongTrail)
	$Sprite/SmokeTrail.emitting = false
	$ExplosionParticlesFire.emitting = true
	$ExplosionParticlesRed.emitting = true
	Globals.remove_particle($Sprite/SmokeTrail)
	Globals.remove_particle($ExplosionParticlesFire)
	Globals.remove_particle($ExplosionParticlesRed)
	set_physics_process(false)
	queue_free()
	emit_signal("dead")

func boost():
	emit_signal("boosted")
	$BoostTween.interpolate_property(self, "speed_core_multiplier", 2.0, 1.0, 2.5, Tween.TRANS_LINEAR)
	$BoostTween.start()

var cached_speed: int
func stun():
	
	# we check if cached_speed is zero so that it doesn't set max_speed to 0 permanently
	if cached_speed == 0:
		cached_speed = max_speed
		max_speed = 0
	
	$StunTimer.start(stun_duration)

func _on_StunTimer_timeout():
	#if any speed was added to it while it was stunned
	cached_speed += max_speed
	max_speed = cached_speed
	cached_speed = 0

func _on_VisibilityNotifier2D_screen_entered():
	is_visible = true

func _on_VisibilityNotifier2D_screen_exited():
	is_visible = false


