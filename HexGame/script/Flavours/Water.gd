extends "res://script/Flavours/Empty.gd"

func _ready():
	pass

func proliferate():
	emit_signal("spread_to_neighbour", Global.NORTH)
	emit_signal("spread_to_neighbour", Global.NORTHWEST)
	emit_signal("spread_to_neighbour", Global.NORTHEAST)
	emit_signal("spread_to_neighbour", Global.SOUTHWEST)
	emit_signal("spread_to_neighbour", Global.SOUTH)
	emit_signal("spread_to_neighbour", Global.SOUTHEAST)
	return

func play_pickup_sfx():
	Global.sound_mgr.tilePickupWater()
	return
