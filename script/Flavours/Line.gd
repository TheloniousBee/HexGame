extends "res://script/Flavours/Empty.gd"

signal hex_departed
signal spread_to_end(direction, fill_flavour)

export var direction : int

func _ready():
	connect("spread_to_end", get_parent(), "spread_to_end")
	return

func proliferate():
	emit_signal("spread_to_end", direction, "LinePath")
	return

func play_pickup_sfx():
	Global.sound_mgr.tilePickupLineMaker()
	return
