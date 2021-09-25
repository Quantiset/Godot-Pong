extends Node

var rng_seed := 1000
var randomize_seed := true

func _ready():
	
	rng_seed = clamp(rng_seed, 0, 9999)
	
	if randomize_seed:
		randomize()
		rng_seed = randi()%10000
	
	seed(rng_seed)


func remove_particle(p: Particles2D):
	if not is_instance_valid(p): return
	var pp = p.global_position
	var t = Timer.new()
	p.get_parent().remove_child(p)
	get_node("/root").add_child(p)
	get_node("/root").add_child(t)
	p.position = pp
	t.start(p.lifetime*(1+p.process_material.lifetime_randomness))
	t.connect("timeout", self, "queue_free_all", [[t, p]])

func remove_trail(t: Line2D, fade_duration := 1.0):
	var tw := Tween.new()
	t.get_parent().remove_child(t)
	get_node("/root").add_child(t)
	t.add_child(tw)
	var ta := t.modulate
	ta.a = 0
	tw.interpolate_property(t, "modulate", t.modulate, ta, fade_duration, Tween.TRANS_LINEAR)
	tw.connect("tween_all_completed", self, "queue_free_all", [[t]])
	tw.start()

func queue_free_all(arr: Array):
	for obj in arr:
		obj.queue_free()


