extends Node2D

onready var items := [$Item, $Item2, $Item3]
var fade_time := 0.75

func _ready():
	
	for item in items:
		item.type = Globals.parse_pool(Globals.ITEM_POOL)


func _on_Item_picked_up(_item: int):
	
	for item in items:
		item.set_deferred("monitoring", false)
		item.get_node("Particles2D").emitting = false
		$Tween.interpolate_property(item.get_node("Sprite"), "modulate", Color(1,1,1), Color(1,1,1,0), fade_time, Tween.TRANS_LINEAR)
	$Tween.start()
	
	yield(get_tree().create_timer(fade_time), "timeout")
	queue_free()
	

