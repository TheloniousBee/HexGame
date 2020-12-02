extends Node2D

const Hex = preload("res://scene/Hex.tscn")


var MAX_COL_SIZE = 7
var MAX_ROW_SIZE = 15

var spacer = 3
var x_spacing = 24
var y_spacing = 27
var hex_offset_x = x_spacing+spacer
var hex_offset_y = y_spacing+spacer

var col_size = 7
var row_size = 15

#var origin_hex = Vector2(16,14)
#var origin_hex = Vector2(178,46)
var hex_grid_width = row_size * hex_offset_x
var hex_grid_height = col_size * hex_offset_y

var origin_hex : Vector2

var columns = []

# Called when the node enters the scene tree for the first time.
func _ready():
	origin_hex = Vector2((get_viewport().size.x / 2) - (hex_grid_width / 2 - (hex_offset_x / 2)), (get_viewport().size.y / 2) - (hex_grid_height / 2 - (hex_offset_y / 2)))
	setup_grid()
	#setup_grid_old()
	build_grid_from_coordinates_test()
	return
	
func setup_grid():
	for n in MAX_COL_SIZE:
		var row = []
		columns.append(row)
	print(columns.size())
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
		
	for i in range(loaded_grid.size()):
		var row = columns[i]
		for j in loaded_grid[i]:
			var x_pos : int
			var y_pos : int
			if (j.x as int) % 2 != 0:
				x_pos = j.x*27
				y_pos = j.y*30 + (30/2)
			else:
				x_pos = j.x*27
				y_pos = j.y*30
			var hex = Hex.instance()
			hex.on_grid = true
			hex.grid_coordinate = Vector2(j.x,j.y)
			hex.position = Vector2(origin_hex.x + x_pos, origin_hex.y + y_pos)
			add_child(hex)
			row.append(hex)
			
	#for i in columns:
	#	print(i)
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
