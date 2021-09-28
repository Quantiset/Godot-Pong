extends StandardEnemy


func _ready() -> void:
	acceleration *= 2
	max_hp *= 2.5
	hp = max_hp
	max_speed = 100
	shoot_rate = 150
