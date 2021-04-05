extends "res://script/Flavours/Empty.gd"

export var direction : int

signal spread_to_multiple_neighbours(directions)

func _ready():
	connect("spread_to_multiple_neighbours", get_parent(), "spread_to_multiple_neighbours")
	return

func proliferate():
	var direction_array = [direction, (direction+3)%6]
	emit_signal("spread_to_multiple_neighbours", direction_array)
	return

func play_pickup_sfx():
	Global.sound_mgr.tilePickupBidirect()
	return

