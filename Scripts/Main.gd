extends StaticBody2D

const ENEMY_SIGNALER = preload("res://Scenes/EnemySignaler.tscn")

var is_boss_alive := false
var enemies_left := 0
var wave := 1

var stage: int setget set_stage, get_stage

onready var player: KinematicBody2D = $Player

signal spawned_enemy(enemy)
signal wave_begun(wave_idx)

func _ready():
	
	connect("wave_begun", self, "on_wave_begun")
	
	gen_random_spawn(randi()%3+2)

onready var spawnable_space: Vector2 = $ReferenceRect.rect_size
func gen_random_spawn(enemies: int, automatically_add_to_enemies_left := true):
	var xcoor: int = randi() % int(spawnable_space.x)
	var ycoor: int = randi() % int(spawnable_space.y)
	var randomized_spawn: Vector2 = $ReferenceRect.rect_position + Vector2(xcoor, ycoor)
	
	var s = ENEMY_SIGNALER.instance()
	s.position = randomized_spawn
	add_child(s)
	s.get_node("AnimationPlayer").play("Dilate")
	
	yield(s.get_node("AnimationPlayer"), "animation_finished")
	
	s.queue_free()
	
	for i in range(enemies):
		if automatically_add_to_enemies_left:
			enemies_left += 1
		var e := get_random_enemy_per_weights().instance()
		e.position = randomized_spawn + Vector2(randi()%20-10, randi()%20-10)
		e.get_node("InitParticles/SpawnParticles").position = randomized_spawn
		e.get_node("InitParticles/SpawnParticles").emitting = true
		e.get_node("InitParticles/SpawnParticles2").position = randomized_spawn
		e.get_node("InitParticles/SpawnParticles2").emitting = true
		e.connect("dead", self, "on_Enemy_dead")
		e.connect("dead", player, "on_Enemy_dead", [e])
		emit_signal("spawned_enemy", e)
		add_child(e)
		yield(get_tree().create_timer(0.2), "timeout")

func get_random_enemy_per_weights() -> PackedScene:
	
	var ENEMIES: Dictionary = Globals.ENEMY_POOL[get_stage()]
	
	if ENEMIES == null:
		printerr("Main.gd: ENEMIES_POOL not defined for stage " + str(get_stage()))
		breakpoint
	
	return Globals.parse_pool(ENEMIES)


func on_Enemy_dead():
	
	player.xp += 10
	player.update_xp()
	
	enemies_left -= 1
	if enemies_left == 0:
		
		# does not increment the wave counter while boss is alive; continues spawning enemies
		if not is_boss_alive:
			wave += 1
		
		emit_signal("wave_begun", wave)

func on_wave_begun(_wave_idx: int):
	
	player.get_node("CanvasLayer/WaveLabel").text = str(wave)
	
	var randomized_extra_enemies := randi() % int(min(wave*2+2, 7))
	var total_enemies := get_stage() * 2 + 5 + randomized_extra_enemies
	var placeoffs: int = randi()%2+1
	
	# spawns boss
	if wave % 5 == 0 and not is_boss_alive:
		is_boss_alive = true
		
		var boss_inst: Boss
		if Globals.BOSS_STAGE.has(get_stage()):
			boss_inst = Globals.BOSS_STAGE[get_stage()]
		else:
			boss_inst = Globals.BOSS_STAGE[null] 
		
		var boss: Boss = preload("res://Scenes/Enemies/NormalBoss.tscn").instance()
		call_deferred("add_child", boss)
		boss.position = $ReferenceRect.rect_position + $ReferenceRect.rect_size/2
		boss.connect("dead", self, "on_Boss_dead")
		$AudioStreamPlayer.stream = preload("res://Assets/SoundEffects/Orbital Colossus.mp3")
		$AudioStreamPlayer.play()
	
	enemies_left += total_enemies
	for i in range(placeoffs):
		if i != 0 and i == placeoffs-1:
			gen_random_spawn(total_enemies/placeoffs + total_enemies % placeoffs, false)
		else:
			gen_random_spawn(total_enemies/placeoffs, false)
		yield(get_tree().create_timer(randi() % 3 + 2), "timeout") 

func set_stage(_val): pass
func get_stage() -> int:
	return 1 + (wave-1)/5


func on_Boss_dead():
	is_boss_alive = false
	$AudioStreamPlayer.stream = preload("res://Assets/SoundEffects/Thrust Sequence.mp3")
	$AudioStreamPlayer.play()

onready var audio_tween: Tween = $AudioStreamPlayer/Tween
func _on_Player_taken_damage(damage):
	if damage > 0:
		audio_tween.interpolate_property($AudioStreamPlayer, "pitch_scale", 0.5, 1, 1.5, Tween.TRANS_LINEAR)
		audio_tween.interpolate_property($AudioStreamPlayer, "volume_db", -25, -17, 1.5, Tween.TRANS_LINEAR)
		audio_tween.start()
