extends "res://script/Flavours/Empty.gd"

export var direction : int

func _ready():
	pass

func proliferate():
	emit_signal("spread_to_neighbour", direction)
	#Spread in opposite direction
	emit_signal("spread_to_neighbour", (direction+3) % 6)
	return

func play_pickup_sfx():
	Global.sound_mgr.tilePickupBidirect()
	return

