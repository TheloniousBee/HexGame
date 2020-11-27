extends Node2D

var grid_coordinate : Vector2

func _ready():
	$Label.text = (grid_coordinate.x as String) + "," + (grid_coordinate.y as String)
	return


func _on_Area2D_body_shape_entered(body_id, body, body_shape, area_shape):
	body.call("add_hex_to_list", self)
	return
	
	


func _on_Area2D_body_shape_exited(body_id, body, body_shape, area_shape):
	body.call("remove_hex_from_list", self)
	return
