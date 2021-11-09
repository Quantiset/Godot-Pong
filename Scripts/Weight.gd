extends Item

func update_type():
	price = 250
	paid = true
	$PriceLabel.text = str(price)


func pickup(player):
	get_parent().clear_shop(false)
	get_parent().spawn_shop()
	
	# shouldn't delete the weight
	return false

