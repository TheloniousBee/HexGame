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

var level_directory = []

var level_directory_file = "res://levels.dat"

var flavour_dictionary = {
	"Empty":0,
	"Clone":5,
	"Key": 10,
	"LinePath":190,
	"N_Line":200,
	"NE_Line":200,
	"SE_Line":200,
	"S_Line":200,
	"SW_Line":200,
	"NW_Line":200,
	"N_Pathmaker":250,
	"NE_Pathmaker":250,
	"SE_Pathmaker":250,
	"S_Pathmaker":250,
	"SW_Pathmaker":250,
	"NW_Pathmaker":250,
	"Path":300,
	"Water":500,
	"Land":600,
	"N_Traveller":750,
	"NE_Traveller":750,
	"SE_Traveller":750,
	"S_Traveller":750,
	"SW_Traveller":750,
	"NW_Traveller":750,
	"N_Bidirect":800,
	"NE_Bidirect":800,
	"NW_Bidirect":800,
	"CCW_Rotator":900,
	"CW_Rotator":900,
	"Reverse":900,
	"Rubble":990,
	"Mountain":1000,
	"Lock":10000,
}

var sound_mgr : Node
