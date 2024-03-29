extends Area2D

export var speed = 30
export var flavour_type = "Empty"
var grid_coordinate : Vector2
var is_dragging = false
export var on_grid = false
var colliding_hexes = []
var candidate_flavours = {}
var final_candidate_flavour = ""
var original_placeable_pos : Vector2

var safe : bool = true

const LetGoParticle = preload("res://scene/Particle/LetGoParticles.tscn")

export var interactable = false

signal player_made_move
signal move_is_resolved(hexpos)
signal clone_is_resolved()
signal hex_spread_to_neighbour(hex, direction)
signal hex_spread_to_multiple_neighbours(hex, directions)
signal hex_spread_to_end(hex, direction, fill_flavour)
signal hex_won(coord)
signal picked_up_hex
signal hex_let_go
signal tile_becomes_placeable(flavour)
signal show_hex_overlays(flavour_val)
signal hide_hex_overlays()

func _ready():
	set_flavour()
	connect("player_made_move", get_parent(), "record_game_state")
	connect("move_is_resolved", get_parent(), "player_move_successful")
	connect("clone_is_resolved", get_parent(), "advance_turn")
	connect("hex_spread_to_neighbour", get_parent(), "spread_to_neighbour")
	connect("hex_spread_to_multiple_neighbours", get_parent(), "spread_to_multiple_neighbours")
	connect("hex_spread_to_end", get_parent(), "spread_to_end")
	connect("hex_won", get_parent(), "process_post_battle")
	connect("picked_up_hex", get_parent(), "hex_picked_up")
	connect("hex_let_go", get_parent(), "hex_released")
	connect("tile_becomes_placeable", get_parent().get_parent(), "add_placeable_hex")
	connect("show_hex_overlays", get_parent(), "show_overlays_on_grid")
	connect("hide_hex_overlays", get_parent(), "hide_overlays_on_grid")
	return
	
func set_coordinate_text():
	$CoordinateLabel.text = (grid_coordinate.x as String) + "," + (grid_coordinate.y as String)
	return

func _on_Hex_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	if on_grid and area != null and interactable:
		area.call("add_grid_hex_to_list", self)
	return


func _on_Hex_area_shape_exited(_area_id, area, _area_shape, _self_shape):
	if on_grid and area != null and interactable:
		area.call("remove_grid_hex_from_list", self)
	return

func _physics_process(delta):
	if on_grid == false:
		var velocity = Vector2()
		if is_dragging:
			var new_position = get_global_mouse_position()
			velocity = new_position - position;
			
		position += velocity*delta*speed
		#Keep within bounds of screen
		if(position.x > ProjectSettings.get_setting("display/window/size/width")):
			position.x = ProjectSettings.get_setting("display/window/size/width")
		elif position.x < 0:
			position.x = 0
		if(position.y > ProjectSettings.get_setting("display/window/size/height")):
			position.y = ProjectSettings.get_setting("display/window/size/height")
		elif position.y < 0:
			position.y = 0
			
	return

func _on_Hex_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if Global.is_level_editor:
				if event.pressed:
					if on_grid:
						#Painting tiles
						get_tree().get_root().find_node("LevelEditor", true, false).change_flavour(self)
					else:
						#Picking palette
						get_tree().get_root().find_node("LevelEditor", true, false).change_paintbrush(self)
			else:
				if !on_grid:
					#Pick tile up
					if(get_parent().hex_selected == false):
						is_dragging = true
						emit_signal("picked_up_hex")
						play_pickup_sfx()
						show_hex_glow()
						show_possible_placements()
					#Put tile down
					if not event.pressed:
						if(get_parent().hex_selected == true):
							is_dragging = false
							center_on_grid_hex()
							emit_signal("hex_let_go")
							hide_hex_glow()
							hide_possible_placements()
	return
	
func center_on_grid_hex():
	if !colliding_hexes.empty():
		var closest_hex = Node2D.new()
		closest_hex.position = Vector2(100000,100000)
		for hex in colliding_hexes:
			if hex.position.distance_to(position) < closest_hex.position.distance_to(position):
				if hex.interactable:
					closest_hex = hex
		position = closest_hex.position
		place_on_grid(closest_hex)
	else:
		#Placing the tile off the grid
		tile_let_go()
	return

func place_on_grid(hex : Node2D):
	var move_failed = false
	#If the hex to be placed is a higher value than the one on the grid, we replace
	if(hex.flavour_type == "Key"):
		move_failed = true
	elif(Global.flavour_dictionary.get(flavour_type) > Global.flavour_dictionary.get(hex.flavour_type)):
		emit_signal("player_made_move")
		hex.change_hex_type(flavour_type)
		hex.emit_place_particles()
		emit_signal("move_is_resolved", original_placeable_pos)
		play_placed_sfx()
		call_deferred("queue_free")
	elif(flavour_type == "Key" and hex.flavour_type == "Lock"):
		#Special case for Lock/Key, we resolve by destroying both.
		emit_signal("player_made_move")
		hex.change_hex_type("Empty")
		emit_signal("move_is_resolved", original_placeable_pos)
		play_placed_sfx()
		call_deferred("queue_free")
	elif(flavour_type == "Clone"):
		emit_signal("player_made_move")	
		change_hex_type(hex.flavour_type)
		position = original_placeable_pos
		play_placed_sfx()
		emit_signal("clone_is_resolved")
	else:
		move_failed = true
		
	if move_failed:
		#Reset position if the player makes a illegal move
		position = original_placeable_pos
		play_failed_sfx()
	return

func change_hex_type(new_flavour : String):
	if new_flavour != flavour_type:
		flavour_type = new_flavour
		set_flavour()
	return

func add_grid_hex_to_list(hex : Node):
	colliding_hexes.append(hex)
	return
	
func remove_grid_hex_from_list(hex : Node):
	var search_result = colliding_hexes.find(hex)
	if search_result != -1:
		colliding_hexes.remove(search_result)
	return

func set_flavour():
	if has_node("Flavour"):
		var existing_flavour_instance = get_node("Flavour")
		remove_child(existing_flavour_instance)
		existing_flavour_instance.queue_free()
	var flavour_string = "res://scene/Flavours/"
	flavour_string += flavour_type
	flavour_string += ".tscn"
	var flavour = load(flavour_string).instance()
	add_child(flavour)
	return
	
func play_pickup_sfx():
	if has_node("Flavour"):
		get_node("Flavour").play_pickup_sfx()
	return

func add_candidate(new_flavour : String, coord : Vector2):
	candidate_flavours[coord] = new_flavour
	return
	
func resolve_competition():
	if !candidate_flavours.empty():
		var highest_value_flavour = -1
		var second_highest_value = -1
		var second_highest_flavour = ""
		var new_flavour = ""
		var winning_hex : Vector2
		for f in candidate_flavours.keys():
			var flavour_val = Global.flavour_dictionary.get(candidate_flavours.get(f))
			if(flavour_val > highest_value_flavour):
				new_flavour = candidate_flavours.get(f)
				winning_hex = f
				highest_value_flavour = flavour_val
			elif(flavour_val == highest_value_flavour):
				second_highest_value = flavour_val
				second_highest_flavour = candidate_flavours.get(f)
		
		if(Global.flavour_dictionary.get(new_flavour) > Global.flavour_dictionary.get(flavour_type)):
			#If we have a draw, create a Rubble. Draws only happen if two different tiles with the same value win the candidacy
			if(second_highest_value == highest_value_flavour and second_highest_flavour != new_flavour):
				final_candidate_flavour = "Rubble"
			else:
				final_candidate_flavour = new_flavour
				message_winner(winning_hex)
		
		if final_candidate_flavour != "":
			#Process anything that this hex does just before being changed
			if has_node("Flavour"):
				var flavour = get_node("Flavour")
				flavour.lost()
			
			
		candidate_flavours.clear()
	return
	
func message_winner(coord : Vector2):
	emit_signal("hex_won", coord)
	return
	
func resolve_post_win():
	if has_node("Flavour"):
		var flavour = get_node("Flavour")
		flavour.won()
	return

func transform_to_new_flavour():
	if(final_candidate_flavour != ""):
		change_hex_type(final_candidate_flavour)
		final_candidate_flavour = ""
	return

func proliferate():
	if has_node("Flavour"):
		var flavour = get_node("Flavour")
		flavour.proliferate()
	return
	
func spread_to_neighbour(direction):
	emit_signal("hex_spread_to_neighbour", self, direction)
	return
	
func spread_to_multiple_neighbours(directions):
	emit_signal("hex_spread_to_multiple_neighbours", self, directions)
	return
	
func spread_to_end(direction, fill_flavour):
	emit_signal("hex_spread_to_end", self, direction, fill_flavour)
	return
	
func delete_flavour_from_hex():
	change_hex_type("Empty")
	return
	
func leave_path_behind():
	change_hex_type("Path")
	return
	
func leave_linepath_behind():
	change_hex_type("LinePath")
	return
	
func return_tile_to_inventory():
	emit_signal("tile_becomes_placeable", flavour_type)
	return
	
func reflect(sending_hex : Node2D):
	if has_node("Flavour"):
		var flavour = get_node("Flavour")
		if("reflects" in flavour and flavour.reflects == true):
			match flavour_type:
				"CCW_Rotator":
					sending_hex.rotate_counterclockwise()
				"CW_Rotator":
					sending_hex.rotate_clockwise()
				"Reverse":
					sending_hex.reverse()
	return
	
func rotate_clockwise():
	if has_node("Flavour"):
		var flavour = get_node("Flavour")
		if("direction" in flavour):
			var str_arr = flavour_type.rsplit("_")
			var base_name = str_arr[1]
			if base_name == "Bidirect":
				match flavour.direction:
					Global.NORTHWEST:
						change_hex_type("N_" + base_name)
					Global.NORTHEAST:
						change_hex_type("NW_" + base_name)
					Global.NORTH:
						change_hex_type("NE_" + base_name)
			else:
				match flavour.direction:
					Global.SOUTHEAST:
						change_hex_type("S_" + base_name)
					Global.NORTHEAST:
						change_hex_type("SE_" + base_name)
					Global.NORTH:
						change_hex_type("NE_" + base_name)
					Global.NORTHWEST:
						change_hex_type("N_" + base_name)
					Global.SOUTHWEST:
						change_hex_type("NW_" + base_name)
					Global.SOUTH:
						change_hex_type("SW_" + base_name)
		else:
			print_debug("Tried to rotate non-rotating tile")
	return
	
func rotate_counterclockwise():
	if has_node("Flavour"):
		var flavour = get_node("Flavour")
		if("direction" in flavour):
			var str_arr = flavour_type.rsplit("_")
			var base_name = str_arr[1]
			if base_name == "Bidirect":
				match flavour.direction:
					Global.NORTHWEST:
						change_hex_type("NE_" + base_name)
					Global.NORTHEAST:
						change_hex_type("N_" + base_name)
					Global.NORTH:
						change_hex_type("NW_" + base_name)
			else:
				match flavour.direction:
					Global.SOUTHEAST:
						change_hex_type("NE_" + base_name)
					Global.NORTHEAST:
						change_hex_type("N_" + base_name)
					Global.NORTH:
						change_hex_type("NW_" + base_name)
					Global.NORTHWEST:
						change_hex_type("SW_" + base_name)
					Global.SOUTHWEST:
						change_hex_type("S_" + base_name)
					Global.SOUTH:
						change_hex_type("SE_" + base_name)
		else:
			print_debug("Tried to rotate non-rotating tile")
	return
	
func reverse():
	if has_node("Flavour"):
		var flavour = get_node("Flavour")
		if("direction" in flavour):
			var str_arr = flavour_type.rsplit("_")
			var base_name = str_arr[1]
			if base_name != "Bidirect":
				match flavour.direction:
					Global.SOUTHEAST:
						change_hex_type("NW_" + base_name)
					Global.NORTHEAST:
						change_hex_type("SW_" + base_name)
					Global.NORTH:
						change_hex_type("S_" + base_name)
					Global.NORTHWEST:
						change_hex_type("SE_" + base_name)
					Global.SOUTHWEST:
						change_hex_type("NE_" + base_name)
					Global.SOUTH:
						change_hex_type("N_" + base_name)
		else:
			print_debug("Tried to reverse non-rotating tile")
	return

func play_placed_sfx():
	Global.sound_mgr.tilePlaceSuccess()
	return
	
func play_failed_sfx():
	Global.sound_mgr.tilePlaceFail()
	return

func emit_place_particles():
	$PlaceParticles.emitting = true
	return
	
func show_hex_glow():
	if has_node("Flavour"):
		var glow = get_node("Flavour/Glow")
		glow.visible = true
	return

func hide_hex_glow():
	if has_node("Flavour"):
		var glow = get_node("Flavour/Glow")
		glow.visible = false
	return
	
func tile_let_go():
	if !safe:
		position = original_placeable_pos
	var let_go_cloud = LetGoParticle.instance()
	let_go_cloud.emitting = true
	add_child(let_go_cloud)
	Global.sound_mgr.letTilego()
	return


func show_possible_placements():
	var flavour_val = Global.flavour_dictionary.get(flavour_type)
	#If clone, we can just place anywhere, so use a super high value
	if(flavour_type == "Clone"):
		flavour_val = 99999
	emit_signal("show_hex_overlays", flavour_val)
	return
	
func hide_possible_placements():
	emit_signal("hide_hex_overlays")
	return

func show_valid_overlay(players_hex_weight):
	var valid = false
	if has_node("Flavour"):
		if players_hex_weight == Global.flavour_dictionary.get("Key") and flavour_type == "Lock":
			valid = true
		elif flavour_type == "Key":
			valid = false
		elif players_hex_weight > (Global.flavour_dictionary.get(flavour_type)):
			valid = true
	if valid:
		var valid_effect = get_node("Flavour/ValidOverlay")
		valid_effect.visible = true
	return
	
func hide_valid_overlay():
	if has_node("Flavour"):
		var valid_effect = get_node("Flavour/ValidOverlay")
		valid_effect.visible = false
	return
	
func show_invalid_overlay(players_hex_weight):
	var invalid = false
	if has_node("Flavour"):
		if players_hex_weight == Global.flavour_dictionary.get("Key") and flavour_type == "Lock":
			invalid = false
		elif flavour_type == "Key":
			invalid = true
		elif players_hex_weight <= (Global.flavour_dictionary.get(flavour_type)):
			invalid = true
	if invalid:
		var invalid_effect = get_node("Flavour/InvalidOverlay")
		invalid_effect.visible = true
	return
	
func hide_invalid_overlay():
	if has_node("Flavour"):
		var invalid_effect = get_node("Flavour/InvalidOverlay")
		invalid_effect.visible = false
	return

func entered_forbidden_zone():
	safe = false
	return
	
func exited_forbidden_zone():
	safe = true
	return
