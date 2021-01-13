extends Node

var paintbrush : Node2D
var example_hex_grid : Node2D
var playable_hex_grid : Node2D
var cell_controls_list = []
var cell_controls_visible = true

func _ready():
	paintbrush = get_node("PaintBrush")
	Global.is_level_editor = true
	example_hex_grid = get_node("ExampleHexGrid")
	playable_hex_grid = get_node("PlayableHexGrid")
	example_hex_grid.initialize_full_size_grid()
	playable_hex_grid.initialize_full_size_grid()
	setup_row_controls()
	return

func change_flavour(clicked_hex : Node2D):
	clicked_hex.change_hex_type(paintbrush.flavour_type)
	return

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP and event.pressed:
			paintbrush.increment_flavour()
		if event.button_index == BUTTON_WHEEL_DOWN and event.pressed:
			paintbrush.decrement_flavour()
	return
	
func setup_row_controls():
	var index = 0
	for i in example_hex_grid.columns:
		var back_hex = i.back()
		add_row_controls(back_hex, index)
		index += 1
	return

func add_row_controls(hex : Node2D, index : int):
	var cell_controls_resource = load("res://scene/LevelEditor/CellControls.tscn")
	var cell_controls = cell_controls_resource.instance()
	
	#A bit of positioning mess here, 99 is just the size of the 4 buttons	
	cell_controls.margin_left = ProjectSettings.get_setting("display/window/size/width") - 99
	if (hex.grid_coordinate.x) as int % 2 != 0:
		cell_controls.margin_top = hex.position.y - 15 - (cell_controls.rect_size.y / 2)
	else:
		cell_controls.margin_top = hex.position.y - (cell_controls.rect_size.y / 2)
	cell_controls.row_index = index
	cell_controls.visible = cell_controls_visible
	add_child(cell_controls)
	cell_controls_list.append(cell_controls)
	return
	
func recenter_row_controls():
	var index = 0
	for i in example_hex_grid.columns:
		if cell_controls_list[index] != null:
			var hex = i.back()
			var cell_controls = cell_controls_list[index]
			if (hex.grid_coordinate.x) as int % 2 != 0:
				cell_controls.margin_top = hex.position.y - 15 - (cell_controls.rect_size.y / 2)
			else:
				cell_controls.margin_top = hex.position.y - (cell_controls.rect_size.y / 2)
		index += 1
	return

func _on_Save_pressed():
	var saved_level = File.new()
	saved_level.open("D://Game Development/Godot Projects/HexGame/leveldevelopment/new_level.txt", File.WRITE)
	
	var grid = get_node("PlayableHexGrid")
	var grid_size = []
	grid_size.append(grid.row_size)
	grid_size.append(grid.col_size)
	saved_level.store_line(to_json(grid_size))
	
	var placeable_hexes = []
	for i in get_tree().get_nodes_in_group("placeable"):
		if i.flavour_type != "Empty":
			placeable_hexes.append(i.flavour_type)
	saved_level.store_line(to_json(placeable_hexes))
	
	var start_of_playable_grid = "PlayableGrid:"
	saved_level.store_line((start_of_playable_grid))
	
	for i in grid.columns:
		var row = []
		for j in i:
			row.append(j.grid_coordinate)
			row.append(j.flavour_type)
		saved_level.store_line(to_json(row))
		
	var start_of_example_grid = "ExampleGrid:"
	saved_level.store_line((start_of_example_grid))
	
	var example_grid = get_node("ExampleHexGrid")
	for i in example_grid.columns:
		var row = []
		for j in i:
			row.append(j.grid_coordinate)
			row.append(j.flavour_type)
		saved_level.store_line(to_json(row))
	saved_level.close()
	return


func _on_RemoveRow_pressed():
	var old_size = example_hex_grid.columns.size()
	example_hex_grid.change_column_count(example_hex_grid.columns.size()-1)
	playable_hex_grid.change_column_count(playable_hex_grid.columns.size()-1)
	var new_size = example_hex_grid.columns.size()
	
	if new_size < old_size:
		cell_controls_list.pop_back().queue_free()
		recenter_row_controls()
	return


func _on_AddRow_pressed():
	var old_size = example_hex_grid.columns.size()
	example_hex_grid.change_column_count(example_hex_grid.columns.size()+1)
	playable_hex_grid.change_column_count(playable_hex_grid.columns.size()+1)
	var new_size = example_hex_grid.columns.size()
	
	if new_size > old_size:
		var last_row = example_hex_grid.columns.back()
		var last_hex = last_row.back()
		var new_row_controls = add_row_controls(last_hex,example_hex_grid.columns.size()-1)
		recenter_row_controls()
	return


func shift_row_right(index):
	example_hex_grid.shift_row_right(index)
	playable_hex_grid.shift_row_right(index)
	return


func shift_row_left(index):
	example_hex_grid.shift_row_left(index)
	playable_hex_grid.shift_row_left(index)
	return


func add_cell_to_row(index):
	example_hex_grid.increment_row_size(index)
	playable_hex_grid.increment_row_size(index)
	return


func remove_cell_from_row(index):
	example_hex_grid.decrement_row_size(index)
	playable_hex_grid.decrement_row_size(index)
	return

func _on_RowControlsVisibility_pressed():
	var row_controls_visible_button = get_node("RowControlsVisibility")
	if cell_controls_visible:
		row_controls_visible_button.text = "Show Row Controls"
		cell_controls_visible = false
		for i in cell_controls_list:
			i.visible = false
	else:
		row_controls_visible_button.text = "Hide Row Controls"
		cell_controls_visible = true
		for i in cell_controls_list:
			i.visible = true
	return
