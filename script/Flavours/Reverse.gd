extends "res://script/Flavours/Empty.gd"

var reflects = true

func _ready():
	pass

func play_pickup_sfx():
	Global.sound_mgr.tilePickupReverse()
	return
