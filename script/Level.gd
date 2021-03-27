extends Node

signal continue_pressed
signal return_pressed
signal reset_pressed
signal return_to_editor
signal reset_playtest

const Hex = preload("res://scene/Hex.tscn")

var hex_selected = false

var playtest = false
var undo_grid_stack = []
var undo_placeable_stack = []

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
	connect("reset_pressed", get_parent(), "reset_level")
	connect("return_to_editor", get_parent(), "nav_to_editor")
	connect("reset_playtest", get_parent(), "reset_playtest_level")
	return

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_SPACE:
			record_and_advance()
		if event.scancode == KEY_ESCAPE and event.pressed:
			return_to_previous_screen()
	return
	
func return_to_previous_screen():
	if playtest:
		emit_signal("return_to_editor")
	else:
		emit_signal("return_pressed")
	return

func record_game_state():
	#Put playable tiles and playable grid onto the stack
	var placeable_hexes = []
	for i in get_tree().get_nodes_in_group("placeable"):
		var tile = []
		tile.append(i.original_placeable_pos)
		tile.append(i.flavour_type)
		placeable_hexes.append(tile)
	undo_placeable_stack.append(placeable_hexes)
	
	var grid = get_node("PlayHexGrid")
	undo_grid_stack.append(grid.get_whole_grid_state())
	return

func player_move_successful(hexpos : Vector2):
	#Free up a 'slot' and then sort the remaining positions
	placeable_hex_positions.append(hexpos)
	placeable_hex_positions.sort()
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
	
func record_and_advance():
	record_game_state()
	advance_turn()
	return

func check_victory():
	var play_grid = get_node("PlayHexGrid")
	
	if(play_grid.is_grid_full()):
		level_completed()
	return
	
func reverse_turn():
	#get last snapshot off top of stack
	var last_grid_state
	var last_placeable_tile_state
	if(undo_grid_stack.size() == 1 and undo_placeable_stack.size() == 1):
		#don't pop off
		last_grid_state = undo_grid_stack.back()
		last_placeable_tile_state  = undo_placeable_stack.back()
	else:
		last_grid_state = undo_grid_stack.pop_back()
		last_placeable_tile_state  = undo_placeable_stack.pop_back()
	
	for i in get_tree().get_nodes_in_group("placeable"):
		i.queue_free()
	
	for tile in last_placeable_tile_state:
		var hex = Hex.instance()
		hex.on_grid = false
		hex.position = tile[0]
		hex.original_placeable_pos = hex.position
		hex.interactable = false
		hex.add_to_group("placeable")
		add_child(hex)
		hex.change_hex_type(tile[1])
		
	var grid = get_node("PlayHexGrid")
	for row in last_grid_state:
		while(!row.empty()):
			#There could be an issue here if the array isn't even sized
			var coord = row.pop_front()
			var flavour = row.pop_front()
			var hex = grid.get_hex_for_coord(coord)
			hex.change_hex_type(flavour)
			hex.candidate_flavours.clear()
			
	return

func start_play_timer():
	$TurnTimer.start()
	return
	
func stop_play_timer():
	$TurnTimer.stop()
	return
	
func _on_TurnTimer_timeout():
	record_and_advance()
	return
	
func get_next_available_placeable_slot():
	var position : Vector2
	if placeable_hex_positions.empty():
		printerr("No more positions available")
	else:
		position = placeable_hex_positions.pop_front()
	return position

func add_placeable_hex(flavour : String):
	var hex = Hex.instance()
	hex.on_grid = false
	hex.position = get_next_available_placeable_slot()
	hex.original_placeable_pos = hex.position
	hex.interactable = false
	hex.add_to_group("placeable")
	add_child(hex)
	hex.change_hex_type(flavour)
	return

func level_completed():
	stop_play_timer()
	if playtest:
		emit_signal("return_to_editor")
	else:
		$LevelFinish.visible = true
	#Mark down the level completed so it can be changed in level select
	return


func _on_Continue_pressed():
	emit_signal("continue_pressed")
	return


func _on_Return_pressed():
	emit_signal("return_pressed")
	return


func _on_Reset_pressed():
	Global.sound_mgr.playReset()
	if playtest:
		emit_signal("reset_playtest")
	else:
		emit_signal("reset_pressed")
	return
	
func hex_picked_up():
	hex_selected = true
	return

func hex_released():
	hex_selected = false
	return
