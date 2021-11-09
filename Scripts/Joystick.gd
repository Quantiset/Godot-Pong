extends TouchScreenButton

#read this vector to see how offset the ball is compared to origin. 
var ball_offset := Vector2()


var init_pos: Vector2
# radius until ball stops following
var clamped_radius := 80

# radius until input from this joystick won't toggle
var follow_radius := 300

var is_moving := false

func _ready():
	init_pos = global_position

func _input(event):
	
	if "position" in event:
		if event.position.distance_to(init_pos) > follow_radius:
			return
	
	# detects if joystick is being moved
	if (event is InputEventScreenDrag) or (event is InputEventScreenTouch and event.is_pressed()):
		
		if event.position.distance_to(init_pos) > clamped_radius:
			if not is_moving:
				return
		else:
			is_moving = true
		
		# clamps the button to the outer joystick
		global_position = (
			init_pos + ((event.position - normal.get_size()/2) - init_pos).clamped(clamped_radius)
		)
		
		ball_offset = global_position - init_pos
	
	if event is InputEventScreenTouch and not event.is_pressed():
		is_moving = false
		global_position = init_pos
		ball_offset = global_position - init_pos
