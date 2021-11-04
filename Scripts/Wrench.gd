extends Item


func update_type():
	price = 50
	paid = true
	$PriceLabel.text = str(price)


func pickup(player):
	if player.hp == player.max_hp:
		# if player is at full health, don't take the scrap or heal
		player.scrap += price
		return false
	player.take_damage(-50)
	return true
