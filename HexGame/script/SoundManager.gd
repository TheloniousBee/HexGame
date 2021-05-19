extends Node

func _ready():
	pass
	
#Individual functions for each sound effect.
#If I want to swap out which sound effect plays, or reorder them, 
#or do multiple things here, it will be easier in the future.

func playMainMenuClick():
	get_node("Menu/MainMenuClick").play()
	return
	
func playOptionClick():
	get_node("Menu/OptionClick").play()
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
	get_node("TileSounds/AgogoBellG4").play()
	return
	
func tilePickupKey():
	get_node("TileSounds/AgogoBellF4").play()
	return
	
func tilePickupLinePath():
	get_node("TileSounds/AgogoBellE4").play()
	return
	
func tilePickupLineMaker():
	get_node("TileSounds/AgogoBellE4").play()
	return

func tilePickupPathmaker():
	get_node("TileSounds/AgogoBellD4").play()
	return
	
func tilePickupPath():
	get_node("TileSounds/AgogoBellD4").play()
	return

func tilePickupWater():
	get_node("TileSounds/AgogoBellC4").play()
	return
	
func tilePickupLand():
	get_node("TileSounds/AgogoBellB3").play()
	return
	
func tilePickupTraveller():
	get_node("TileSounds/AgogoBellA3").play()
	return

func tilePickupBidirect():
	get_node("TileSounds/AgogoBellG3").play()
	return
	
func tilePickupRotator():
	get_node("TileSounds/AgogoBellF3").play()
	return
	
func tilePickupReverse():
	get_node("TileSounds/AgogoBellE3").play()
	return
	
func tilePickupRubble():
	get_node("TileSounds/AgogoBellD3").play()
	return
	
func tilePickupMountain():
	get_node("TileSounds/AgogoBellD3").play()
	return
	
func tilePickupLock():
	get_node("TileSounds/AgogoBellC3").play()
	return
