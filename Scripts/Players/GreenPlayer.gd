extends Player



func _ready():
	add_item(Items.PanicButton)
	add_item(Items.PoisionMixture)
	max_hp = 150
	max_speed = 250
