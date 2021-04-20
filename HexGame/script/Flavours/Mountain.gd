extends "res://script/Flavours/Empty.gd"

func _ready():
	pass

func play_pickup_sfx():
	Global.sound_mgr.tilePickupMountain()
	return
