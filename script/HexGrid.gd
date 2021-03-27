extends Node2D

const Hex = preload("res://scene/Hex.tscn")


var MAX_COL_SIZE = 7
var MAX_ROW_SIZE = 13

var spacer = 3
var x_spacing = 24
var y_spacing = 27
var hex_offset_x = x_spacing+spacer
var hex_offset_y = y_spacing+spacer

var col_size = 0
var row_size = 0

#var origin_hex = Vector2(16,14)
#var origin_hex = Vector2(178,46)

export var coordinates_showing : bool
export var origin_hex : Vector2
export var placeable : bool

var centered_origin_hex : Vector2


var columns = []

# Called when the node enters the scene tree for the first time.
func _ready():
	return

func set_origin(r_size : int, c_size : int):
	var hex_grid_width = r_size * hex_offset_x
	var hex_grid_height = c_size * hex_offset_y
	centered_origin_hex.x = origin_hex.x - (hex_grid_width / 2)
	centered_origin_hex.y = origin_hex.y - (hex_grid_height / 2)
	return
	
func recenter_grid():
	var previous_origin = centered_origin_hex
	var min_hex = 0
	var max_hex = 0
	for i in columns:
		if !i.empty():
			if i.back().grid_coordinate.x > max_hex:
				max_hex = i.back().grid_coordinate.x
			if i.front().grid_coordinate.x < min_hex:
				min_hex = i.front().grid_coordinate.x
	var r_size = max_hex - min_hex
	var c_size = columns.size()
	
	set_origin(r_size, c_size)
	for i in columns:
		for j in i:
			j.position.x += -previous_origin.x + centered_origin_hex.x
			j.position.y += -previous_origin.y + centered_origin_hex.y
	return	

func initialize_full_size_grid():
	set_origin(MAX_ROW_SIZE, MAX_COL_SIZE)
	for i in MAX_COL_SIZE:
		columns.append(create_empty_row(i, MAX_ROW_SIZE))
	return
	
func convert_grid_coord_to_pos(coordinate : Vector2):
	var new_pos = Vector2.ZERO
	var x_pos : int
	var y_pos : int
	if (coordinate.x as int) % 2 != 0:
		x_pos = coordinate.x*hex_offset_x
		y_pos = coordinate.y*hex_offset_y + (hex_offset_y/2)
	else:
		x_pos = coordinate.x*hex_offset_x
		y_pos = coordinate.y*hex_offset_y
	new_pos = Vector2(centered_origin_hex.x + x_pos, centered_origin_hex.y + y_pos)
	return new_pos
	
func create_empty_hex(coord : Vector2):
	var x_pos : int
	var y_pos : int
	if (coord.x as int) % 2 != 0:
		x_pos = coord.x*hex_offset_x
		y_pos = coord.y*hex_offset_y + (hex_offset_y/2)
	else:
		x_pos = coord.x*hex_offset_x
		y_pos = coord.y*hex_offset_y
	var hex = Hex.instance()
	hex.on_grid = true
	hex.grid_coordinate = Vector2(coord.x,coord.y)
	hex.position = Vector2(centered_origin_hex.x + x_pos, centered_origin_hex.y + y_pos)
	hex.interactable = placeable
	if(coordinates_showing):
		hex.set_coordinate_text()
	add_child(hex)
	return hex

func create_empty_row(column_pos, new_row_size):
	var row = []
	for i in new_row_size:
		row.append(create_empty_hex(Vector2(i,column_pos)))
	return row
	
func change_column_count(new_col_count : int):
	if new_col_count > 0 and new_col_count <= MAX_COL_SIZE:
		if(new_col_count > columns.size()):
			while(columns.size() < new_col_count):
				var last_row_size = columns.back().size()
				var new_row = create_empty_row(columns.size(),last_row_size)
				columns.append(new_row)
		elif(new_col_count < columns.size()):
			while(columns.size() > new_col_count):
				for i in columns.back():
					i.queue_free()
				columns.pop_back()
		recenter_grid()
	return
	
func shift_row_right(index : int):
	if(index >= 0 and index <= columns.size()-1):
		var row = columns[index]
		if(row.back().grid_coordinate.x < MAX_ROW_SIZE):
			for i in row:
				i.grid_coordinate.x += 1
				i.position = convert_grid_coord_to_pos(i.grid_coordinate)
				i.set_coordinate_text()
		recenter_grid()
	return
	
func shift_row_left(index : int):
	if(index >= 0 and index <= columns.size()-1):
		var row = columns[index]
		if(row.front().grid_coordinate.x > 0):
			for i in row:
				i.grid_coordinate.x -= 1
				i.position = convert_grid_coord_to_pos(i.grid_coordinate)
				i.set_coordinate_text()
		recenter_grid()
	return
	
func increment_row_size(index : int):
	if(index >= 0 and index <= columns.size()-1):
		var row = columns[index]
		if(row.size() < MAX_ROW_SIZE):
			var last_hex = row.back()
			var new_hex = create_empty_hex(Vector2(last_hex.grid_coordinate.x+1,index))
			row.append(new_hex)
		recenter_grid()
	return

func decrement_row_size(index : int):
	if(index >= 0 and index <= columns.size()-1):
		var row = columns[index]
		if(row.size() > 1):
			row.back().queue_free()
			row.pop_back()
		recenter_grid()
	return

func proliferate_hexes():
	for hex in get_children():
		hex.proliferate()
	
	for hex in get_children():
		hex.resolve_competition()
		
	for hex in get_children():
		hex.transform_to_new_flavour()
	return

func spread_to_neighbour(original_hex : Node2D, direction : int):
	var hex = get_hex_for_coord(get_neighbour(original_hex.grid_coordinate,direction))
	if hex != null:
		hex.add_candidate(original_hex.flavour_type, original_hex.grid_coordinate)
		hex.reflect(original_hex)
		return

func process_post_battle(coord : Vector2):
	var hex = get_hex_for_coord(coord)
	hex.resolve_post_win()
	return

var directions = [
	#Even columns
	[[1,0],[1,-1],[0,-1],
	[-1,-1],[-1,0],[0,1]],
	#Odd columns
	[[1,1],[1,0],[0,-1],
	[-1,0],[-1,1],[0,1]]
]

func get_neighbour(coordinate : Vector2, direction : int):
	#0 direction = southeast
	#1 direction = northeast
	#2 direction = north
	#3 direction = northwest
	#4 direction = southwest
	#5 direction = south
	if direction < 0 or direction > 5:
		printerr("Bad neighbour direction.")
		return
	var parity = coordinate.x as int % 2
	var dir = directions[parity][direction]
	return Vector2(coordinate.x+dir[0],coordinate.y+dir[1])

func get_hex_for_coord(coordinate : Vector2):
	#print("Getting hex for:" + (coordinate as String))
	if coordinate.y >= columns.size() or coordinate.y < 0:
		return null
	else:
		var row = columns[coordinate.y]
		if row.empty():
			return null
		else:
			#Since our arrays can start with a non-0 coordinate, adjust for that here
			var row_start = row.front().grid_coordinate.x
			if coordinate.x - row_start >= row.size() or coordinate.x - row_start < 0:
				return null
			else:
				return row[coordinate.x-row_start]

func get_whole_grid_state():
	var grid_state = []
	for i in columns:
		var row = []
		for j in i:
			row.append(j.grid_coordinate)
			row.append(j.flavour_type)
		grid_state.append(row)
	return grid_state
	
func is_grid_full():
	for i in columns:
		for j in i:
			if j.flavour_type == "Empty":
				return false
	return true
