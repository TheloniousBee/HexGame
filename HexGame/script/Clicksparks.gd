extends Particles2D

func _on_DeleteThis_timeout():
	queue_free()
	return
