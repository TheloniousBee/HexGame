extends "res://script/Hex.gd"

var flavour_list = [
	"Empty",
	"Glacier",
	"Grass",
	"Lava",
	"Mountain",
	"Village",
	"Water"
]

var flavour_index = 0

func _ready():
	pass

func increment_flavour():
	if(flavour_list.size() <= flavour_index+1):
		flavour_index = 0
	else:
		flavour_index += 1
	flavour_type = flavour_list[flavour_index]
	set_flavour()
	return
	
func decrement_flavour():
	if(flavour_index-1 < 0):
		flavour_index = flavour_list.size()-1
	else:
		flavour_index -= 1
	flavour_type = flavour_list[flavour_index]
	set_flavour()
	return
