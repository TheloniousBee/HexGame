extends KinematicBody2D

var is_dragging = false

func _ready():
	pass

func _physics_process(delta):
	var movement = Vector2()
	
	if is_dragging:
		var new_position = get_global_mouse_position()
		movement = new_position - position;
	move_and_collide(movement)
	return


func _on_Tile_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			is_dragging = event.pressed
	return
