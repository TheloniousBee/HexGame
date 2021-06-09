extends Control

export var unlock_threshold: int

func _ready():
	$StarCount.text = unlock_threshold as String
	return
	
func assign_level_nums(first_level_num):
	$LevelButtonN.assign_level_num(first_level_num)
	$LevelButtonNW.assign_level_num(first_level_num+1)
	$LevelButtonNE.assign_level_num(first_level_num+2)
	$LevelButtonSW.assign_level_num(first_level_num+3)
	$LevelButtonSE.assign_level_num(first_level_num+4)
	$LevelButtonS.assign_level_num(first_level_num+5)
	return

func disable_hub():
	$LevelButtonN.disabled = true
	$LevelButtonNW.disabled = true
	$LevelButtonNE.disabled = true
	$LevelButtonSW.disabled = true
	$LevelButtonSE.disabled = true
	$LevelButtonS.disabled = true
	$Star.visible = true
	$StarCount.visible = true
	return

func enable_hub():
	if !$LevelButtonN.completed:
		$LevelButtonNW.disabled = true
		$LevelButtonNE.disabled = true
		$LevelButtonSW.disabled = true
		$LevelButtonSE.disabled = true
		$LevelButtonS.disabled = true
	else:
		$LevelButtonNW.disabled = false
		$LevelButtonNE.disabled = false
		$LevelButtonSW.disabled = false
		$LevelButtonSE.disabled = false
		$LevelButtonS.disabled = false
	return
	
func enable_all():
	$LevelButtonN.completed = false
	$LevelButtonNW.disabled = false
	$LevelButtonNE.disabled = false
	$LevelButtonSW.disabled = false
	$LevelButtonSE.disabled = false
	$LevelButtonS.disabled = false
	return
