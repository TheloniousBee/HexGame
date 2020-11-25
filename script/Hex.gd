extends Node2D

var grid_coordinate : Vector2

func _ready():
	$Label.text = (grid_coordinate.x as String) + "," + (grid_coordinate.y as String)
	return
