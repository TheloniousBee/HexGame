extends Area2D

export var speed = 30
export var flavour_type = "Empty"
var grid_coordinate : Vector2
var is_dragging = false
export var on_grid = false
var colliding_hexes = []
var candidate_flavours = []
var original_placeable_pos : Vector2

export var interactable = false

signal player_made_move
signal move_is_resolved
signal hex_spread_to_neighbour(grid_coordinate, direction, flavour_type)

func _ready():
	set_flavour()
	set_coordinate_text()
	connect("player_made_move", get_parent(), "record_game_state")
	connect("move_is_resolved", get_parent(), "advance_turn")
	connect("hex_spread_to_neighbour", get_parent(), "spread_to_neighbour")
	return
	
func set_coordinate_text():
	$CoordinateLabel.text = (grid_coordinate.x as String) + "," + (grid_coordinate.y as String)
	return

func _on_Hex_area_shape_entered(area_id, area, area_shape, self_shape):
	if on_grid and area != null and interactable:
		area.call("add_grid_hex_to_list", self)
	return


func _on_Hex_area_shape_exited(area_id, area, area_shape, self_shape):
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
	return

func _on_Hex_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if !on_grid:
				is_dragging = event.pressed
				if not event.pressed:
					center_on_grid_hex()
			elif Global.is_level_editor:
				if event.pressed:
					get_tree().get_root().get_node("LevelEditor").change_flavour(self)
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
	return

func place_on_grid(hex : Node2D):
	#If the hex to be placed is a higher value than the one on the grid, we replace
	if(Global.flavour_dictionary.get(flavour_type) > Global.flavour_dictionary.get(hex.flavour_type)):
		emit_signal("player_made_move")
		hex.change_hex_type(flavour_type)
		emit_signal("move_is_resolved")
		call_deferred("queue_free")
	else:
		#Reset position if the player makes a illegal move
		position = original_placeable_pos
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

func add_candidate(new_flavour : String):
	candidate_flavours.append(new_flavour)
	return
	
func transform_to_new_flavour():
	if !candidate_flavours.empty():
		var highest_value_flavour = -1
		var new_flavour = ""
		for f in candidate_flavours:
			var flavour_val = Global.flavour_dictionary.get(f)
			if(flavour_val > highest_value_flavour):
				new_flavour = f
				highest_value_flavour = flavour_val
		
		if(Global.flavour_dictionary.get(new_flavour) > Global.flavour_dictionary.get(flavour_type)):
			change_hex_type(new_flavour)
	return

func proliferate():
	if has_node("Flavour"):
		var flavour = get_node("Flavour")
		flavour.proliferate()
	return
	
func spread_to_neighbour(direction):
	emit_signal("hex_spread_to_neighbour", grid_coordinate, direction, flavour_type)
	return
