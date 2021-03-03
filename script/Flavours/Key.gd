extends "res://script/Flavours/Empty.gd"

signal tile_consumed

func _ready():
	connect("tile_consumed", get_parent(), "return_tile_to_inventory")
	return

func lost():
	emit_signal("tile_consumed")
	return
