extends HBoxContainer

var row_index

signal add_cell_pressed(index)
signal remove_cell_pressed(index)
signal shift_row_left_pressed(index)
signal shift_row_right_pressed(index)

func _ready():
	self.connect("add_cell_pressed", get_parent(), "add_cell_to_row")
	self.connect("remove_cell_pressed", get_parent(), "remove_cell_from_row")
	self.connect("shift_row_left_pressed", get_parent(), "shift_row_left")
	self.connect("shift_row_right_pressed", get_parent(), "shift_row_right")
	return

func _on_AddCell_pressed():
	emit_signal("add_cell_pressed", row_index)
	return


func _on_RemoveCell_pressed():
	emit_signal("remove_cell_pressed", row_index)
	return

func _on_ShiftRowLeft_pressed():
	emit_signal("shift_row_left_pressed", row_index)
	return

func _on_ShiftRowRight_pressed():
	emit_signal("shift_row_right_pressed", row_index)
	return
