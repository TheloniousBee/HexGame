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
	"res://levels/bouncy.lvl",
]

var flavour_dictionary = {
	"Empty":0,
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
}
