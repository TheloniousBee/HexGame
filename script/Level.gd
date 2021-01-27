extends Node

signal continue_pressed
signal return_pressed

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
	$LevelFinish.visible = false
	connect("continue_pressed", get_parent(), "continue_to_next_level")
	connect("return_pressed", get_parent(), "return_to_level_select")
	return

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_SPACE:
			advance_turn()
	return

func advance_turn():
	#Activate each Hexes "Spread" function
	#Each spread function will mark hexes that it would like to spread to
	#Each hex will then resolve the conflicts for all the candidate spread
	var grid = get_node("PlayHexGrid")
	grid.proliferate_hexes()
	
	#Check if level has been completed
	check_victory()
	return

func check_victory():
	var play_grid = get_node("PlayHexGrid")
	var example_grid = get_node("ExampleHexGrid")
	
	if(play_grid.get_whole_grid_state() == example_grid.get_whole_grid_state()):
		level_completed()
	return
	
func reverse_turn():
	
	return

func start_play_timer():
	$TurnTimer.start()
	return
	
func stop_play_timer():
	$TurnTimer.stop()
	return
	
func _on_TurnTimer_timeout():
	advance_turn()
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

func level_completed():
	stop_play_timer()
	$LevelFinish.visible = true
	#Mark down the level completed so it can be changed in the level editor
	return


func _on_Continue_pressed():
	emit_signal("continue_pressed")
	return


func _on_Return_pressed():
	emit_signal("return_pressed")
	return
