extends Node


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
