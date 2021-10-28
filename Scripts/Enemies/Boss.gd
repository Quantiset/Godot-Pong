extends Actor
class_name Boss

onready var player = get_tree().get_nodes_in_group("Player")[0]

var current_state := -1
var time_in_this_state := 0.0
var damage_in_this_state := 0

signal dead()

func _ready():
	update_health()
	
	player.get_node("CanvasLayer/BossBar").visible = true

func _physics_process(delta: float) -> void:
	time_in_this_state += delta
	
	for trail in $Trails.get_children():
		trail.add_point(position + trail.position.rotated(rotation) + Vector2(0, -40))
		
		var max_points = trail_length if trail == $Trails/LongTrail else thrust_length
		
		if trail.get_point_count() > max_points:
			trail.remove_point(0)
	
	move_and_slide(velocity)


func take_damage(damage: int):
	hp -= damage
	hp = clamp(hp, -1, max_hp)
	damage_in_this_state += damage
	if hp <= 0:
		emit_signal("dead")
		delete()
	update_health()

func update_health():
	var boss_progress: TextureProgress = player.get_node("CanvasLayer/BossBar")
	
	player.get_node("CanvasLayer/BossBar/HPLabel").text = str(hp) + "/" + str(max_hp)
	boss_progress.get_node("Tween").interpolate_property(
		boss_progress, "value", boss_progress.value, float(hp)/max_hp * 100, 0.3, Tween.TRANS_LINEAR
	)
	boss_progress.get_node("Tween").start()
	boss_progress.get_node("AnimationPlayer").play("Flash")

func delete():
	var item = preload("res://Scenes/BossDrop.tscn").instance()
	get_parent().call_deferred("add_child", item)
	item.position = position
	player.shake_amount += 5
	player.get_node("CanvasLayer/BossBar").visible = false
	queue_free()


func laser_wall():
	var amount := 10
	var size : float = player.get_node("../ReferenceRect").get_global_rect().size.y
	var step := size/amount
	
	var lasers := []
	
	for i in range(amount):
		var l := preload("res://Scenes/Bullets/Laser.tscn").instance()
		get_parent().add_child(l)
		var p := AnimationPlayer.new()
		l.get_node("AnimationPlayer").playback_speed = 0.5
		lasers.append(l)
		l.position = Vector2(15, step * i)
	
	var t := Timer.new()
	get_node("/root").add_child(t)
	t.start(1.6)
	t.connect("timeout", self, "on_LaserWall_complete", [lasers, t])

func on_LaserWall_complete(lasers: Array, timer: Timer):
	for laser in lasers:
		laser.delete()
	
	timer.queue_free()

func set_state(state: int):
	current_state = state
	time_in_this_state = 0.0
	damage_in_this_state = 0
