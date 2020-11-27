extends Node

func _ready():
	pass

func advance_turn():
	var grid = get_node("HexGrid")
	grid.proliferate_hexes()
	return
