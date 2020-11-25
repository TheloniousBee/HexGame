extends Node2D

const Hex = preload("res://scene/Hex.tscn")


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var spacer = 3
var x_spacing = 24
var y_spacing = 27
var hex_offset_x = x_spacing+spacer
var hex_offset_y = y_spacing+spacer

var col_size = 9
var row_size = 9

#var origin_hex = Vector2(16,14)
#var origin_hex = Vector2(178,46)
var hex_grid_width = row_size * hex_offset_x
var hex_grid_height = col_size * hex_offset_y

var origin_hex : Vector2

var columns = []

# Called when the node enters the scene tree for the first time.
func _ready():
	origin_hex = Vector2((get_viewport().size.x / 2) - (hex_grid_width / 2), (get_viewport().size.y / 2) - (hex_grid_height / 2))
	setup_grid()
	#build_grid_from_coordinates_test()
	return
	
func setup_grid():
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
			hex.grid_coordinate = Vector2(j,i)
			hex.position = Vector2(origin_hex.x + x_pos, origin_hex.y + y_pos)
			add_child(hex)
			row.append(hex.grid_coordinate)
		columns.append(row)
	return

func build_grid_from_coordinates_test():
	var row1 = []
	var row2 = []
	var row3 = []
	row1.append(Vector2(3,0))
	row2.append(Vector2(2,1))
	row2.append(Vector2(3,1))
	row2.append(Vector2(4,1))
	row3.append(Vector2(2,2))
	row3.append(Vector2(3,2))
	row3.append(Vector2(4,2))
	columns.append(row1)
	columns.append(row2)
	columns.append(row3)
	
	for i in columns:
		print(i)
		
	for row in columns:
		for j in row:
			var x_pos : int
			var y_pos : int
			if (j.x as int) % 2 != 0:
				x_pos = j.x*27
				y_pos = j.y*30 + (30/2)
			else:
				x_pos = j.x*27
				y_pos = j.y*30
			var hex = Hex.instance()
			hex.grid_coordinate = Vector2(j.x,j.y)
			hex.position = Vector2(origin_hex.x + x_pos, origin_hex.y + y_pos)
			add_child(hex)
			
	for i in columns:
		print(i)
	return


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
