extends StaticBody2D

func _process(delta):
	$ParallaxBackground/ParallaxLayer.motion_offset += Vector2(20, 20) * delta
	$ParallaxBackground/ParallaxLayer2.motion_offset += Vector2(15, 17) * -delta
