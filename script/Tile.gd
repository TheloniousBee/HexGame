extends KinematicBody2D

var is_dragging = false
var locked = false

var colliding_hexes = []

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
		if event.button_index == BUTTON_LEFT and !locked:
			is_dragging = event.pressed
			if not event.pressed:
				center_on_hex()
	return

func center_on_hex():
	if !colliding_hexes.empty():
		var closest_hex = Vector2(100000,100000)
		for hex in colliding_hexes:
			if hex.position.distance_to(position) < closest_hex.distance_to(position):
				closest_hex = hex.position
		position = closest_hex
		locked = true
	return

func add_hex_to_list(hex : Node):
	colliding_hexes.append(hex)
	print(colliding_hexes)
	return
	
func remove_hex_from_list(hex : Node):
	var search_result = colliding_hexes.find(hex)
	if search_result != -1:
		colliding_hexes.remove(search_result)
		
	print(colliding_hexes)
	return
