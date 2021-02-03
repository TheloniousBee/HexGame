extends Node

enum {
	SOUTHEAST,
	NORTHEAST
	NORTH,
	NORTHWEST,
	SOUTHWEST,
	SOUTH
}

var is_level_editor = false

var level_directory = [
	"res://levels/test_level1.txt",
]

var flavour_dictionary = {
	"Empty":0,
	"Water":500,
	"Mountain":1000,
}
