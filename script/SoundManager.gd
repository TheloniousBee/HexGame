extends Node

func _ready():
	pass
	
#Individual functions for each sound effect.
#If I want to swap out which sound effect plays, or reorder them, 
#or do multiple things here, it will be easier in the future.

func playMainMenuClick():
	get_node("Menu/MainMenuClick").play()
	return

func playUndoButton():
	get_node("Menu/MainMenuClick").play()
	return
	
func playPauseButton():
	get_node("Menu/MainMenuClick").play()
	return
	
func playForwardStep():
	get_node("Menu/MainMenuClick").play()
	return

func playReset():
	get_node("Menu/MainMenuClick").play()
	return
	
func letTilego():
	get_node("TileSounds/TileLetGo").play()
	return
	
func tilePlaceFail():
	get_node("TileSounds/TilePlaceFail").play()
	return
	
func tilePlaceSuccess():
	get_node("TileSounds/TilePlaceSuccess").play()
	return
	
func tilePickupClone():
	get_node("TileSounds/TilePickupOct6").play()
	return
	
func tilePickupKey():
	get_node("TileSounds/TilePickupOct6").play()
	return
	
func tilePickupLinePath():
	get_node("TileSounds/TilePickupOct6").play()
	return
	
func tilePickupLineMaker():
	get_node("TileSounds/TilePickupOct6").play()
	return

func tilePickupPathmaker():
	get_node("TileSounds/TilePickupOct5").play()
	return
	
func tilePickupPath():
	get_node("TileSounds/TilePickupOct5").play()
	return

func tilePickupWater():
	get_node("TileSounds/TilePickupOct4").play()
	return
	
func tilePickupLand():
	get_node("TileSounds/TilePickupOct4").play()
	return
	
func tilePickupTraveller():
	get_node("TileSounds/TilePickupOct4").play()
	return

func tilePickupBidirect():
	get_node("TileSounds/TilePickupOct3").play()
	return
	
func tilePickupRotator():
	get_node("TileSounds/TilePickupOct3").play()
	return
	
func tilePickupReverse():
	get_node("TileSounds/TilePickupOct3").play()
	return
	
func tilePickupRubble():
	get_node("TileSounds/TilePickupOct3").play()
	return
	
func tilePickupMountain():
	get_node("TileSounds/TilePickupOct3").play()
	return
	
func tilePickupLock():
	get_node("TileSounds/TilePickupOct3").play()
	return
