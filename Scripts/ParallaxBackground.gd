extends ParallaxBackground

const ARENA_SIZE = Vector2(1750,1750)

onready var planet1 = get_node("Planet1/Position2D/Planet")
onready var planet1_center = get_node("Planet1/Position2D")
var p1_orbit_radius = 0
var p1_orbit_speed = 0
var p1_rotation_speed = 0

onready var planet2 = get_node("Planet2/Position2D/Planet")
onready var planet2_center = get_node("Planet2/Position2D")
var p2_orbit_radius = 0
var p2_orbit_speed = 0
var p2_rotation_speed = 0

var rng = RandomNumberGenerator.new()

onready var middle = $Middle/ColorRect.material.get_shader_param("NOISE_PATTERN")
onready var near = $Near/ColorRect.material.get_shader_param("NOISE_PATTERN")


func _ready():
	rng.randomize()
	initialize_planets()
	middle.noise.seed = rng.randi()
	$Middle/ColorRect.material.set_shader_param("COLOR_", __get_color_rgb(planet2.modulate))
	near.noise.seed = rng.randi() - 2
	$Near/ColorRect.material.set_shader_param("COLOR_", __get_color_rgb(planet1.modulate))
	

func _physics_process(delta):
	
	planet1_center.rotation += p1_orbit_speed * delta
	planet1.rotation += p1_rotation_speed * delta
	
	planet2_center.rotation += p2_orbit_speed * delta
	planet2.rotation += p2_rotation_speed * delta

func initialize_planets():
	planet1.modulate = _get_random_color(rng)
	planet1.scale = Vector2.ONE * _randi_range_except(-4,4,rng,[0]) / 4
	p1_orbit_radius = rng.randi()%200 + 500
	p1_orbit_speed = (rng.randi()%5)/20 + 0.05
	p1_rotation_speed = -((rng.randi()%5)/10 + 0.1)
	planet1_center.position = _get_random_point_in_area(ARENA_SIZE/2,rng) + ARENA_SIZE/4
	planet1.position = Vector2(0,rng.randi()%200 + 500)
	
	planet2.modulate = _get_random_color(rng)
	planet2.scale = Vector2.ONE * _randi_range_except(-4,4,rng,[0]) / 4
	p2_orbit_radius = rng.randi()%200 + 500
	p2_orbit_speed = -((rng.randi()%5)/20 + 0.05)
	p2_rotation_speed = (rng.randi()%5)/10 + 0.1
	planet2_center.position = Vector2(planet1_center.position.y,planet1_center.position.x)
	planet2.position = Vector2(0,rng.randi()%200 + 500) * -1
	

func _get_random_color(random):
	return Color(clamp(random.randf() + 0.2,0.0,1.0),clamp(random.randf() + 0.2,0.0,1.0),clamp(random.randf() + 0.2,0.0,1.0),1)

func _randi_range_except(range_min, range_max, rng, exceptions):
	var number = rng.randi_range(range_min,range_max)
	if exceptions.has(number):
		return 1
	return number

func _get_random_point_in_area(area, rng):
	return Vector2(rng.randi_range(0,area.x), rng.randi_range(0,area.y))

func __get_color_rgb(color):
	return Vector3(color.r,color.g,color.b)
