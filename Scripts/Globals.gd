extends Node


func remove_particle(caller, p: Particles2D, override_emitting: bool):
	if not is_instance_valid(p): return
	var pp = p.global_position
	var t = Timer.new()
	if override_emitting:
		p.emitting = false
	p.get_parent().remove_child(p)
	get_node("/root").add_child(p)
	get_node("/root").add_child(t)
	p.position = pp
	t.start(p.lifetime*(1+p.process_material.lifetime_randomness))
	t.connect("timeout", self, "queue_free_all", [[t, p]])

func queue_free_all(arr: Array):
	for obj in arr:
		obj.queue_free()


const ITEMS = { }
