extends Button

var row_index

signal add_cell_pressed(index)

func _ready():
	self.connect("add_cell_pressed", get_parent(), "add_cell_to_row")
	return

func _on_AddCell_pressed():
	emit_signal("add_cell_pressed", row_index)
	return
