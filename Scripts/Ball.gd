extends RigidBody2D

export (int) var max_points := 20

onready var line : Line2D = $Node/Line2D

func _physics_process(delta: float):
	
	line.add_point(position)
	if line.get_point_count() > max_points:
		line.remove_point(0)
