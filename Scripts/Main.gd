extends StaticBody2D

const ENEMY_SIGNALER := preload("res://Scenes/EnemySignaler.tscn")

const ENEMY := preload("res://Scenes/Enemy.tscn")

var enemies_left := 0
var stage := 1

func _ready():
	gen_random_spawn(stage)

func gen_random_spawn(enemies := 1):
	var space: Vector2 = $BottomRight.position - $TopLeft.position
	var xcoor: int = randi() % int(space.x)
	var ycoor: int = randi() % int(space.y)
	var randomized_spawn: Vector2 = $TopLeft.position + Vector2(xcoor, ycoor)
	
	var s = ENEMY_SIGNALER.instance()
	s.position = randomized_spawn
	add_child(s)
	s.get_node("AnimationPlayer").play("Dilate")
	
	yield(s.get_node("AnimationPlayer"), "animation_finished")
	
	s.queue_free()
	
	for i in range(enemies):
		enemies_left += 1
		var e := ENEMY.instance()
		e.position = randomized_spawn + Vector2((randi()%20*i)-10, (randi()%20)*i-10)
		e.get_node("InitParticles/SpawnParticles").position = randomized_spawn
		e.get_node("InitParticles/SpawnParticles").emitting = true
		e.get_node("InitParticles/SpawnParticles2").position = randomized_spawn
		e.get_node("InitParticles/SpawnParticles2").emitting = true
		e.connect("dead", self, "on_Enemy_dead")
		add_child(e)
		yield(get_tree().create_timer(0.2), "timeout")


func _process(delta: float) -> void:
	$ParallaxBackground/ParallaxLayer.motion_offset += Vector2(22, 18) * delta
	$ParallaxBackground/ParallaxLayer2.motion_offset += Vector2(15, 17) * delta

func on_Enemy_dead():
	enemies_left -= 1
	stage += 1
	if enemies_left == 0:
		gen_random_spawn(stage)
