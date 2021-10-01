extends Node

var rng_seed := 1000
var randomize_seed := true

const BIT_WORLD = 0
const BIT_PLAYER = 1
const BIT_ENEMY = 2

# each pool for each stage. Initial key is the weight
const ENEMY_POOL = {
	1: {
		preload("res://Scenes/Enemies/StandardEnemy.tscn"): 5,
		preload("res://Scenes/Enemies/StandardTurret.tscn"): 1,
	},
	2: {
		preload("res://Scenes/Enemies/StandardEnemy.tscn"): 4,
		preload("res://Scenes/Enemies/ExplodingEnemy.tscn"): 3,
		preload("res://Scenes/Enemies/StandardTurret.tscn"): 2,
	},
	3: {
		preload("res://Scenes/Enemies/StandardTurret.tscn"): 4,
		preload("res://Scenes/Enemies/ExplodingEnemy.tscn"): 4,
		preload("res://Scenes/Enemies/StandardDreadnought.tscn"): 2,
		preload("res://Scenes/Enemies/StandardEnemy.tscn"): 2,
	},
	4: {
		preload("res://Scenes/Enemies/ExplodingEnemy.tscn"): 6,
		preload("res://Scenes/Enemies/StandardTurret.tscn"): 8,
		preload("res://Scenes/Enemies/StandardEnemy.tscn"): 2,
		preload("res://Scenes/Enemies/StandardDreadnought.tscn"): 4,
	},
	5: {
		preload("res://Scenes/Enemies/ExplodingEnemy.tscn"): 3,
		preload("res://Scenes/Enemies/StandardTurret.tscn"): 5,
		preload("res://Scenes/Enemies/ExplodingDreadnought.tscn"): 1,
		preload("res://Scenes/Enemies/StandardDreadnought.tscn"): 7,
	}
}

var ITEM_POOL := {
	Items.HeatseekingMissiles: 6,
	Items.LeadTippedDarts: 10,
	Items.RefinedPlating: 10,
	Items.RubberBullets: 10,
	Items.DoubledMuzzle: 6,
	Items.Grenade: 10,
	Items.MachineGun: 4,
}

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
		if is_instance_valid(obj):
			obj.queue_free()

func parse_pool(POOL: Dictionary):
	var num_sum := 0
	
	for i in POOL.values():
		num_sum += i
	
	var random_num: int = randi()%num_sum
	
	for pool_entry in POOL.keys():
		random_num -= POOL[pool_entry]
		if random_num < 0:
			return pool_entry
