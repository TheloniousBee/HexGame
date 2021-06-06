extends Control
	
func assign_level_nums(first_level_num):
	$LevelButtonN.assign_level_num(first_level_num)
	$LevelButtonNW.assign_level_num(first_level_num+1)
	$LevelButtonNE.assign_level_num(first_level_num+2)
	$LevelButtonSW.assign_level_num(first_level_num+3)
	$LevelButtonSE.assign_level_num(first_level_num+4)
	$LevelButtonS.assign_level_num(first_level_num+5)
	return
