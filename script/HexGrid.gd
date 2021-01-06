extends Node2D

const Hex = preload("res://scene/Hex.tscn")


var MAX_COL_SIZE = 7
var MAX_ROW_SIZE = 15

var spacer = 3
var x_spacing = 24
var y_spacing = 27
var hex_offset_x = x_spacing+spacer
var hex_offset_y = y_spacing+spacer

var col_size = 0
var row_size = 0

#var origin_hex = Vector2(16,14)
#var origin_hex = Vector2(178,46)


export var origin_hex : Vector2
export var placeable : bool

var columns = []

# Called when the node enters the scene tree for the first time.
func _ready():
	setup_grid()
	#setup_grid_old()
	build_grid_from_coordinates_test()
	return
	
	
func setup_grid():
	for n in MAX_COL_SIZE:
		var row = []
		columns.append(row)
	#print(columns.size())
	return
	
func setup_grid_old():
	for i in col_size:
		var row = []
		for j in row_size:			
			var x_pos : int
			var y_pos : int
			if j % 2 != 0:
				x_pos = j*hex_offset_x
				y_pos = i*hex_offset_y + (hex_offset_y/2)
			else:
				x_pos = j*hex_offset_x
				y_pos = i*hex_offset_y
			var hex = Hex.instance()
			hex.on_grid = true
			hex.grid_coordinate = Vector2(j,i)
			hex.position = Vector2(origin_hex.x + x_pos, origin_hex.y + y_pos)
			add_child(hex)
			row.append(hex)
		columns.append(row)
	return


func build_grid_from_coordinates_test():
	var loaded_grid = []
	for n in MAX_COL_SIZE:
		var row = []
		loaded_grid.append(row)
	var row0 = loaded_grid[0]
	row0.append(Vector2(5,0))
	row0.append(Vector2(6,0))
	row0.append(Vector2(7,0))
	var row1 = loaded_grid[1]
	row1.append(Vector2(3,1))
	row1.append(Vector2(4,1))
	row1.append(Vector2(5,1))
	row1.append(Vector2(6,1))
	row1.append(Vector2(7,1))
	row1.append(Vector2(8,1))
	row1.append(Vector2(9,1))
	var row2 = loaded_grid[2]
	row2.append(Vector2(3,2))
	row2.append(Vector2(4,2))
	row2.append(Vector2(5,2))
	row2.append(Vector2(6,2))
	row2.append(Vector2(7,2))
	row2.append(Vector2(8,2))
	row2.append(Vector2(9,2))
	var row3 = loaded_grid[3]
	row3.append(Vector2(3,3))
	row3.append(Vector2(4,3))
	row3.append(Vector2(5,3))
	row3.append(Vector2(6,3))
	row3.append(Vector2(7,3))
	row3.append(Vector2(8,3))
	row3.append(Vector2(9,3))
	var row4 = loaded_grid[4]
	row4.append(Vector2(3,4))
	row4.append(Vector2(4,4))
	row4.append(Vector2(5,4))
	row4.append(Vector2(6,4))
	row4.append(Vector2(7,4))
	row4.append(Vector2(8,4))
	row4.append(Vector2(9,4))
	var row5 = loaded_grid[5]
	row5.append(Vector2(4,5))
	row5.append(Vector2(5,5))
	row5.append(Vector2(6,5))
	row5.append(Vector2(7,5))
	row5.append(Vector2(8,5))
	var row6 = loaded_grid[6]
	row6.append(Vector2(6,6))
		
	var running_row_size = 0
	var max_row_size = 0
	for i in loaded_grid:
		if !i.empty():
			col_size += 1
			running_row_size = 0
			for j in i:
				running_row_size += 1
			if running_row_size > max_row_size:
				max_row_size = running_row_size
	row_size = max_row_size
	print(col_size)
	print(row_size)
	
	var hex_grid_width = row_size * hex_offset_x
	var hex_grid_height = col_size * hex_offset_y
	#origin_hex = Vector2((get_viewport().size.x / 2) - (hex_grid_width / 2 - (hex_offset_x / 2)), (get_viewport().size.y / 2) - (hex_grid_height / 2 - (hex_offset_y / 2)))
	origin_hex.x -= hex_grid_width - (hex_offset_x)
	origin_hex.y -= hex_grid_height / 2 - (hex_offset_y)
	
	print("Origin_hex")
	print(origin_hex)
	for i in range(loaded_grid.size()):
		var row = columns[i]
		for j in loaded_grid[i]:
			var x_pos : int
			var y_pos : int
			if (j.x as int) % 2 != 0:
				x_pos = j.x*hex_offset_x
				y_pos = j.y*hex_offset_y + (hex_offset_y/2)
			else:
				x_pos = j.x*hex_offset_x
				y_pos = j.y*hex_offset_y
			var hex = Hex.instance()
			hex.on_grid = true
			hex.grid_coordinate = Vector2(j.x,j.y)
			hex.position = Vector2(origin_hex.x + x_pos, origin_hex.y + y_pos)
			hex.interactable = placeable
			add_child(hex)
			row.append(hex)
			
	for i in columns:
		print(i)
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
	new_pos = Vector2(origin_hex.x + x_pos, origin_hex.y + y_pos)
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
	hex.position = Vector2(origin_hex.x + x_pos, origin_hex.y + y_pos)
	hex.interactable = placeable
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
	return
	
func shift_row_right(index : int):
	if(index >= 0 and index <= columns.size()-1):
		var row = columns[index]
		if(row.back().grid_coordinate.x < MAX_ROW_SIZE):
			for i in row:
				i.grid_coordinate.x += 1
				i.position = convert_grid_coord_to_pos(i.grid_coordinate)
				i.set_coordinate_text()
	return
	
func shift_row_left(index : int):
	if(index >= 0 and index <= columns.size()-1):
		var row = columns[index]
		if(row.front().grid_coordinate.x > 0):
			for i in row:
				i.grid_coordinate.x -= 1
				i.position = convert_grid_coord_to_pos(i.grid_coordinate)
				i.set_coordinate_text()
	return
	
func increment_row_size(index : int):
	if(index >= 0 and index <= columns.size()-1):
		var row = columns[index]
		if(row.size() < MAX_ROW_SIZE):
			var last_hex = row.back()
			var new_hex = create_empty_hex(Vector2(last_hex.grid_coordinate.x+1,index))
			row.append(new_hex)
	return

func decrement_row_size(index : int):
	if(index >= 0 and index <= columns.size()-1):
		var row = columns[index]
		if(row.size() > 1):
			row.back().queue_free()
			row.pop_back()
	return

func proliferate_hexes():
	for hex in get_children():
		hex.proliferate()
		
	for hex in get_children():
		hex.transform_to_new_flavour()
	return

func spread_to_neighbour(coord : Vector2, direction : int, flavour : String):
	var hex = get_hex_for_coord(get_neighbour(coord,direction))
	if hex != null:
		hex.add_candidate(flavour)
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
	return
