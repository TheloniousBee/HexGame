extends Node

var paintbrush : Node2D

func _ready():
	paintbrush = get_node("PaintBrush")
	Global.is_level_editor = true
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
