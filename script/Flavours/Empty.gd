extends Node2D

signal spread_to_neighbour(direction)

func _ready():
	self.connect("spread_to_neighbour", get_parent(), "spread_to_neighbour")
	pass

func proliferate():
	pass

func won():
	pass

func lost():
	pass

func reflect():
	pass
