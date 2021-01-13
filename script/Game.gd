extends Node

func _ready():
	load_level_from_file("D://Game Development/Godot Projects/HexGame/leveldevelopment/test_level1.txt")
	return

func load_level_from_file(filepath : String):
	var level = get_node("Level")
	var playable_hex_grid = level.get_node("PlayHexGrid")
	var example_hex_grid = level.get_node("ExampleHexGrid")
	
	#load in the file from a specific path as the function argument
	
	var save_file = File.new()
	if !save_file.file_exists(filepath):
		return
	
	#delete anything we need to from the existing level
	
	save_file.open(filepath, File.READ)
	#get row and column numbers first
	var grid_size_line = save_file.get_line()
	
	#get playable tiles
	var playable_tiles = parse_json(save_file.get_line())
	for i in playable_tiles:
		level.add_placeable_hex(i)
	
	#get playable grid
	var playable_grid_line = save_file.get_line()
	if playable_grid_line == "PlayableGrid:":
		while(save_file.get_position() < save_file.get_len()):
			var line = save_file.get_line()
			if(line.begins_with("ExampleGrid:")):
				break
			else:
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
		
	
	#get example grid
	while(save_file.get_position() < save_file.get_len()):
		var line = save_file.get_line()
		var parsed_line = parse_json(line)
		#Create the row
		var row = []
		while(parsed_line.size() >= 2):
			#Add hex to row, and set coordinate and flavour here
			var coordinate = parsed_line.pop_front()
			var flavour = parsed_line.pop_front()
			var new_hex = example_hex_grid.create_empty_hex(str_to_vec2(coordinate))
			if flavour != "Empty":
				new_hex.change_hex_type(flavour)
			row.append(new_hex)
		example_hex_grid.columns.append(row)
	example_hex_grid.recenter_grid()
	save_file.close()
	return


func str_to_vec2(string : String):
	#Assumption is that the string looks like: "(5,3)"
	var left_stripped_string = string.lstrip("(")
	var stripped_string = left_stripped_string.rstrip(")")
	var vec2 = Array(stripped_string.split(","))
	return Vector2(vec2.front(),vec2.back())
