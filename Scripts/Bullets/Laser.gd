extends Bullet
class_name Laser

var cast_length := 2000
var step := 10

var time := 0.0

var exceptions := []
var immune_time := 0.5

var is_fading_in := true

func _ready():
	if is_fading_in:
		$AnimationPlayer.play("FadeIn")
		yield($AnimationPlayer, "animation_finished")
	$Line2D.modulate = Color("ffffff")
	$Line2D2.modulate = Color("ffffff")
	is_fading_in = false

func _physics_process(delta: float) -> void:
	
	time += delta
	
	var local_collision := Vector2(cast_length, 0)
	
	$RayCast2D.cast_to = Vector2(cast_length, 0)
	if $RayCast2D.is_colliding():
		var collider = $RayCast2D.get_collider()
		var collision_point: Vector2 = $RayCast2D.get_collision_point()
		
		# can't use to_local because of rotation
		local_collision = collision_point - global_position
		
		if collider.has_method("take_damage"):
			
			if is_fading_in:
				return
			
			if not collider in exceptions:
				
				damage_actor(collider)
				exceptions.append(collider)
				
				if pierces > -4:
					pierces -= 1
					$RayCast2D.add_exception(collider)
					$RayCast2D.force_raycast_update()
				else:
					
					# adds to the exception array to create immunity for this node
					var t := Timer.new()
					add_child(t)
					t.start(immune_time)
					t.connect("timeout", self, "on_exception_timeout", [collider, t])
	
	var length_to_collision := local_collision.length()
	var angle_to_collision := local_collision.angle()
	
	# clears all points from line2D
	$Line2D.clear_points()
	$Line2D2.clear_points()
	
	var amount: int = length_to_collision/step
	
	# adds points culminating until collision, with each point being a point in the line2d
	for i in range(amount):
		add_point(Vector2(step, 0) * i, i)
	
	# the final remainder if the step doesn't divide evenly into the length to collision
	if not is_zero_approx(fmod(length_to_collision, step)):
		add_point(Vector2(length_to_collision + fmod(length_to_collision, step), 0), amount)

# adds the point with a sinusoidal offset, creating the laser effect
func add_point(val: Vector2, i: int):
	val += Vector2(0, 3 * sin(2*(i + 2*time)))
	var val2 = val + Vector2(0, 5 * sin(0.5 + 3*(i + 3*time)))
	$Line2D.add_point(val)
	$Line2D2.add_point(val2)

func delete():
	$AnimationPlayer.play("FadeAway")
	yield($AnimationPlayer, "animation_finished")
	queue_free()

func on_exception_timeout(exception, timer):
	exceptions.erase(exception)
	timer.queue_free()

func damage_actor(actor):
	actor.take_damage(get_total_damage())
	emit_signal("damaged_enemy", actor)
