extends StandardEnemy

export (float) var laser_time := 1.3

var lasers = []

func _ready():
	bullet = preload("res://Scenes/Bullets/Laser.tscn")

func shoot():
	var bullets = .shoot()
	for bul in bullets:
		bul.exceptions.append(self)
		lasers.append(bul)
		var t := Timer.new()
		$Sprite.add_child(t)
		bul.rotation = $Sprite.global_rotation - PI/2
		t.start(laser_time)
		t.connect("timeout", self, "on_Laser_timeout", [bul, t])
		bul.get_node("AnimationPlayer").connect("animation_finished", self, "on_laser_warning_finished", [bul])
	return bullets

func on_laser_warning_finished(laser, timer):
	laser.delete()
	timer.queue_free()

func on_animation_finished(bullet):
	lasers.erase(bullet)

func _physics_process(delta: float) -> void:
	for laser in lasers:
		laser.position = position
		laser.rotation = lerp_angle(laser.rotation, (player.position - position).angle(), 0.1)
