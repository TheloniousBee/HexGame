extends Node

var paintbrush : Node2D
var playable_hex_grid : Node2D
var cell_controls_list = []
var cell_controls_visible = true
var palette_visible = false

signal level_editor_reload_pressed()
signal return_to_main_menu
signal playtest_pressed(cache)

func _ready():
	init_palette()
	connect("level_editor_reload_pressed",get_parent(),"load_level_editor")
	connect("playtest_pressed",get_parent(),"load_playtest")
	connect("return_to_main_menu", get_parent(), "load_main_menu")
	paintbrush = get_node("PaintBrush")
	Global.is_level_editor = true
	playable_hex_grid = get_node("PlayableHexGrid")
	return

func init_level_editor():
	#If we're starting the level editor from a blank state, ie. not returning from a playtest
	playable_hex_grid.initialize_full_size_grid()
	setup_row_controls()
	return

func load_playtesting_level(level_data):
	#Load level scene with our cached data
	#get row and column numbers first
	var _grid_size_line = level_data.pop_front()
	
	#get playable tiles
	var playable_tiles = parse_json(level_data.pop_front())
	var editor_placeable_tiles = get_tree().get_nodes_in_group("placeable")
	for i in playable_tiles:
		for j in editor_placeable_tiles:
			if j.flavour_type == "Empty":
				j.change_hex_type(i)
				break
	
	#get playable grid
	var playable_grid_line = level_data.pop_front()
	if playable_grid_line == "PlayableGrid:":
		for line in level_data:
			var parsed_line = parse_json(line)
			#Create the row
			var row = []
			while(parsed_line.size() >= 2):
				#Add hex to row, and set coordinate and flavour here
				var coordinate = parsed_line.pop_front()
				var flavour = parsed_line.pop_front()
				var new_hex = playable_hex_grid.create_empty_hex(str_to_vec2(coordinate))
				if flavour != "Empty":
					new_hex.change_hex_type(flavour)
				row.append(new_hex)
			playable_hex_grid.columns.append(row)
		playable_hex_grid.recenter_grid()
		
	setup_row_controls()
	return

func change_flavour(clicked_hex : Node2D):
	if !palette_visible:
		clicked_hex.change_hex_type(paintbrush.flavour_type)
	return
	
func change_paintbrush(clicked_hex : Node2D):
	#Set our painting tile to the clicked one in the palette,
	#also, make sure we change the index, so we can continue scrolling properly
	var new_flavour = clicked_hex.flavour_type
	paintbrush.change_hex_type(new_flavour)
	$PaintBrush.flavour_index = $PaintBrush.flavour_list.find(new_flavour)
	return

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP and event.pressed:
			paintbrush.increment_flavour()
		if event.button_index == BUTTON_WHEEL_DOWN and event.pressed:
			paintbrush.decrement_flavour()
		#if event.button_index == BUTTON_RIGHT and event.pressed:
			#paintbrush.rotate_clockwise()
	elif event is InputEventKey:
		if event.scancode == KEY_ESCAPE and event.pressed:
			emit_signal("return_to_main_menu")
	return
	
func setup_row_controls():
	var index = 0
	for i in playable_hex_grid.columns:
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
	for i in playable_hex_grid.columns:
		if cell_controls_list[index] != null:
			var hex = i.back()
			var cell_controls = cell_controls_list[index]
			if (hex.grid_coordinate.x) as int % 2 != 0:
				cell_controls.margin_top = hex.position.y - 15 - (cell_controls.rect_size.y / 2)
			else:
				cell_controls.margin_top = hex.position.y - (cell_controls.rect_size.y / 2)
		index += 1
	return

func _on_OK_pressed():
	var saved_level = File.new()
	var level_name = $SaveDialog/LevelName.text
	var filepath = "D://Game Development/Godot Projects/HexGame/leveldevelopment/" + level_name + ".lvl"
	saved_level.open(filepath, File.WRITE)
	
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
	saved_level.close()
	$SaveDialog.visible = false
	return


func _on_RemoveRow_pressed():
	var old_size = playable_hex_grid.columns.size()
	playable_hex_grid.change_column_count(playable_hex_grid.columns.size()-1)
	var new_size = playable_hex_grid.columns.size()
	
	if new_size < old_size:
		cell_controls_list.pop_back().queue_free()
		recenter_row_controls()
	return


func _on_AddRow_pressed():
	var old_size = playable_hex_grid.columns.size()
	playable_hex_grid.change_column_count(playable_hex_grid.columns.size()+1)
	var new_size = playable_hex_grid.columns.size()
	
	if new_size > old_size:
		var last_row = playable_hex_grid.columns.back()
		var last_hex = last_row.back()
		add_row_controls(last_hex,playable_hex_grid.columns.size()-1)
		recenter_row_controls()
	return


func shift_row_right(index):
	playable_hex_grid.shift_row_right(index)
	return


func shift_row_left(index):
	playable_hex_grid.shift_row_left(index)
	return


func add_cell_to_row(index):
	playable_hex_grid.increment_row_size(index)
	return


func remove_cell_from_row(index):
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


func _on_Reload_pressed():
	emit_signal("level_editor_reload_pressed", false)
	return


func _on_Save_pressed():
	$SaveDialog.visible = true
	return


func _on_Cancel_pressed():
	$SaveDialog.visible = false
	return


func _on_Clear_pressed():
	for i in get_tree().get_nodes_in_group("placeable"):
		i.change_hex_type("Empty")
		
	for i in playable_hex_grid.columns:
		for j in i:
			j.change_hex_type("Empty")
	return


func _on_Playtest_pressed():
	Global.is_level_editor = false
	#Cache current level setup so we can return to it later
	var level_cache = []
	var grid = get_node("PlayableHexGrid")
	var grid_size = []
	grid_size.append(grid.row_size)
	grid_size.append(grid.col_size)
	level_cache.append(to_json(grid_size))

	var placeable_hexes = []
	for i in get_tree().get_nodes_in_group("placeable"):
		if i.flavour_type != "Empty":
			placeable_hexes.append(i.flavour_type)
	level_cache.append(to_json(placeable_hexes))
	
	var start_of_playable_grid = "PlayableGrid:"
	level_cache.append((start_of_playable_grid))
	
	for i in grid.columns:
		var row = []
		for j in i:
			row.append(j.grid_coordinate)
			row.append(j.flavour_type)
		level_cache.append(to_json(row))
	
	emit_signal("playtest_pressed", level_cache)
	return
	
func str_to_vec2(string : String):
	#Assumption is that the string looks like: "(5,3)"
	var left_stripped_string = string.lstrip("(")
	var stripped_string = left_stripped_string.rstrip(")")
	var vec2 = Array(stripped_string.split(","))
	return Vector2(vec2.front(),vec2.back())

func init_palette():
	var hex_res = load("res://scene/Hex.tscn")
	var flavour_list = Global.flavour_dictionary.keys()
	var tile_size = 35
	var tiles_per_row = 10
	for i in flavour_list.size():
		var hex = hex_res.instance()
		hex.on_grid = false
		hex.position = Vector2((i % tiles_per_row)*tile_size,(i / tiles_per_row) * tile_size) + Vector2(tile_size,tile_size)
		hex.interactable = false
		hex.flavour_type = flavour_list[i]
		hex.set_flavour()
		$PalettePanel.add_child(hex)
	return

func _on_Palette_pressed():
	if !palette_visible:
		$PalettePanel.visible = true
		palette_visible = true
	else:
		$PalettePanel.visible = false
		palette_visible = false
	return
