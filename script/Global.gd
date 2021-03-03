extends Node

enum {
	SOUTHEAST,
	NORTHEAST,
	NORTH,
	NORTHWEST,
	SOUTHWEST,
	SOUTH
}

var is_level_editor = false

var level_directory = [
	"res://levels/lock_test.lvl",
]

var flavour_dictionary = {
	"Empty":0,
	"Key": 10,
	"N_Pathmaker":250,
	"NE_Pathmaker":250,
	"SE_Pathmaker":250,
	"S_Pathmaker":250,
	"SW_Pathmaker":250,
	"NW_Pathmaker":250,
	"Path":300,
	"Water":500,
	"N_Traveller":750,
	"NE_Traveller":750,
	"SE_Traveller":750,
	"S_Traveller":750,
	"SW_Traveller":750,
	"NW_Traveller":750,
	"CCW_Rotator":900,
	"CW_Rotator":900,
	"Rubble":990,
	"Mountain":1000,
	"Lock":10000,
}
