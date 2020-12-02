extends Area2D

export var speed = 30
export var flavour_type = "Empty"
var grid_coordinate : Vector2
var is_dragging = false
var on_grid = false
var colliding_hexes = []
var candidate_flavours = []

const SOUTHEAST = 0
const NORTHEAST = 1
const NORTH = 2
const NORTHWEST = 3
const SOUTHWEST = 4
const SOUTH = 5

signal player_made_move
signal hex_spread_to_neighbour(grid_coordinate, direction, flavour_type)

func _ready():
	set_flavour()
	$CoordinateLabel.text = (grid_coordinate.x as String) + "," + (grid_coordinate.y as String)
	$Name.text = name
	self.connect("player_made_move", get_parent(), "advance_turn")
	self.connect("hex_spread_to_neighbour", get_parent(), "spread_to_neighbour")
	return

func _on_Hex_area_shape_entered(area_id, area, area_shape, self_shape):
	if on_grid and area != null:
		area.call("add_grid_hex_to_list", self)
	return


func _on_Hex_area_shape_exited(area_id, area, area_shape, self_shape):
	if on_grid and area != null:
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
		if event.button_index == BUTTON_LEFT and !on_grid:
			is_dragging = event.pressed
			if not event.pressed:
				center_on_grid_hex()
	return
	
func center_on_grid_hex():
	if !colliding_hexes.empty():
		var closest_hex = Node2D.new()
		closest_hex.position = Vector2(100000,100000)
		for hex in colliding_hexes:
			if hex.position.distance_to(position) < closest_hex.position.distance_to(position):
				closest_hex = hex
		position = closest_hex.position
		place_on_grid(closest_hex)
	return

func place_on_grid(hex : Node2D):
	hex.change_hex_type(flavour_type)
	emit_signal("player_made_move")
	call_deferred("queue_free")
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
		change_hex_type(candidate_flavours.back())
		print("new coord")
		print(grid_coordinate)
	return

func proliferate():
	if flavour_type != "Empty" and flavour_type != "Mountain":
		match flavour_type:
			"Lava":
				spread_lava()
			"Village":
				spread_village()
			"Glacier":
				spread_glacier()
			"Grass":
				spread_grass()
			"Water":
				spread_water()
	return
	
func spread_lava():
	emit_signal("hex_spread_to_neighbour", grid_coordinate, SOUTH, flavour_type)
	return
	
func spread_village():
	emit_signal("hex_spread_to_neighbour", grid_coordinate, NORTHEAST, flavour_type)
	emit_signal("hex_spread_to_neighbour", grid_coordinate, NORTHWEST, flavour_type)
	emit_signal("hex_spread_to_neighbour", grid_coordinate, SOUTH, flavour_type)
	return
	
func spread_glacier():
	
	return
	
func spread_grass():
	
	return
	
func spread_water():
	emit_signal("hex_spread_to_neighbour", grid_coordinate, NORTHWEST, flavour_type)
	return
