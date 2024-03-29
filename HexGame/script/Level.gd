extends Node

signal continue_pressed
signal return_pressed
signal reset_pressed
signal return_to_editor
signal reset_playtest
signal turn_reversed
signal level_complete

const Hex = preload("res://scene/Hex.tscn")

var hex_selected = false

var playtest = false
var undo_grid_stack = []
var undo_placeable_stack = []
var last_grid_undo_state = []
var last_placeable_undo_state = []

var showing_overlays = false
var last_weight = 0

var placeable_hex_positions = [
	Vector2(190,286),
	Vector2(190,385),
	Vector2(190,484),
	Vector2(190,583),
	Vector2(190,682),
	Vector2(301,286),
	Vector2(301,385),
	Vector2(301,484),
	Vector2(301,583),
	Vector2(301,682)
]

func _ready():	
	$Tutorial/AnimationPlayer.play("TutorialFadeIn")
	$Tutorial/TutorialStay.start()
	$LevelFinish.visible = false
	connect("continue_pressed", get_parent(), "return_to_level_select")
	connect("return_pressed", get_parent(), "return_to_level_select")
	connect("reset_pressed", get_parent(), "reset_level")
	connect("return_to_editor", get_parent(), "nav_to_editor")
	connect("reset_playtest", get_parent(), "reset_playtest_level")
	connect("turn_reversed", get_parent(), "undo_pressed")
	connect("level_complete", get_parent(), "mark_level_as_complete_and_save")
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
	
	var grid = get_node("PlayHexGrid")
	var grid_state = grid.get_whole_grid_state()		
	
	#If both stacks have the same state, don't add a new one ontop.
	if grid_state != last_grid_undo_state or placeable_hexes != last_placeable_undo_state:
		undo_placeable_stack.append(placeable_hexes)
		last_placeable_undo_state = placeable_hexes
		undo_grid_stack.append(grid_state)
		last_grid_undo_state = grid_state
	return

func player_move_successful(hexpos : Vector2):
	#Free up a 'slot' and then sort the remaining positions
	placeable_hex_positions.append(hexpos)
	placeable_hex_positions.sort()
	
	if !$TurnTimer.is_stopped():
		$TurnTimer.start()
	advance_turn()
	return

func advance_turn():
	#Activate each Hexes "Spread" function
	#Each spread function will mark hexes that it would like to spread to
	#Each hex will then resolve the conflicts for all the candidate spread
	var grid = get_node("PlayHexGrid")
	grid.proliferate_hexes()
	
	#Refresh the overlays
	if(showing_overlays):
		show_overlays_on_grid(last_weight)
	
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
	stop_play_timer()
	emit_signal("turn_reversed")
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
	$Tutorial.visible = false
	stop_play_timer()
	$Confetti.emitting = true
	$Confetti2.emitting = true
	
	if playtest:
		emit_signal("return_to_editor")
	else:
		#Start short timer so we can actually see the final result
		$LevelFinishDelay.start()
	#Mark down the level completed so it can be changed in level select
	emit_signal("level_complete")
	
	#Disable buttons
	get_node("TimeControls/Reverse Step").disabled = true
	get_node("TimeControls/Forward Step").disabled = true
	get_node("TimeControls/Play").disabled = true
	return
	
func display_finished_level_dialog():
	$LevelFinish.visible = true
	return


func _on_Continue_pressed():
	emit_signal("continue_pressed")
	Global.sound_mgr.playMainMenuClick()
	return


func _on_Return_pressed():
	emit_signal("return_pressed")
	Global.sound_mgr.playMainMenuClick()
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


func _on_Quit_pressed():
	Global.sound_mgr.playMainMenuClick()
	return_to_previous_screen()
	return

func show_overlays_on_grid(flavour_weight):
	showing_overlays = true
	last_weight = flavour_weight
	var grid = get_node("PlayHexGrid")
	for hex in grid.get_children():
		hex.show_valid_overlay(flavour_weight)
		hex.show_invalid_overlay(flavour_weight)
	return
	
func hide_overlays_on_grid():
	showing_overlays = false
	var grid = get_node("PlayHexGrid")
	for hex in grid.get_children():
		hex.hide_valid_overlay()
		hex.hide_invalid_overlay()
	return


func _on_TutorialStay_timeout():
	$Tutorial/AnimationPlayer.play("TutorialFadeOut")
	return

func speed_up_game(toggled):
	if toggled:
		$TurnTimer.wait_time = 0.001
		#If the timer is already going, skip it now
		if(!$TurnTimer.is_stopped()):
			$TurnTimer.stop()
			$TurnTimer.start()
	else:
		$TurnTimer.wait_time = 1
	return


func _on_Forbidden_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	if area.has_method("entered_forbidden_zone"):
		area.entered_forbidden_zone()
	return


func _on_Forbidden_area_shape_exited(_area_id, area, _area_shape, _self_shape):
	if area.has_method("exited_forbidden_zone"):
		area.exited_forbidden_zone()
	return
