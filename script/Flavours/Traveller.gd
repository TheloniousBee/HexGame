extends "res://script/Flavours/Empty.gd"

export var direction : int

signal hex_departed

func _ready():
	connect("hex_departed", get_parent(), "delete_flavour_from_hex")
	return

func proliferate():
	emit_signal("spread_to_neighbour", direction)
	return

func won():
	emit_signal("hex_departed")
	return
