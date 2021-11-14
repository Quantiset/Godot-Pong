extends Player


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	add_item(Items.RefinedPlating)


func shoot():
	var b_list: Array = .shoot()
	for bullet in b_list:
		bullet.damage -= 5

func set_scrap(val: int):
	.set_scrap(int(val * 1.3))
