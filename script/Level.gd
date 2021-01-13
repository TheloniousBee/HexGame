extends Node

const Hex = preload("res://scene/Hex.tscn")

var placeable_hex_positions = [
	Vector2(21,29),
	Vector2(21,62),
	Vector2(21,95),
	Vector2(21,128),
	Vector2(21,161),
	Vector2(21,194),
	Vector2(21,227),
	Vector2(21,260),
	Vector2(21,293),
	Vector2(21,326),
]

func _ready():
	pass

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_SPACE:
			advance_turn()
	return

func advance_turn():
	var grid = get_node("PlayHexGrid")
	grid.proliferate_hexes()
	
	#Activate its "Spread" function
	#Each spread function will mark hexes that it would like to spread to
	#Each hex will then resolve the conflicts for all the candidate spread
	return

func add_placeable_hex(flavour : String):
	#need to decide on position
	var hex = Hex.instance()
	hex.on_grid = false
	hex.position = placeable_hex_positions.pop_front()
	hex.interactable = false
	add_child(hex)
	hex.change_hex_type(flavour)
	return

