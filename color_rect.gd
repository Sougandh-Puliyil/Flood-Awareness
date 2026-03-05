extends ColorRect

var rise_speed = 5

func _process(delta):

	if position.y > 0:
		position.y -= rise_speed * delta
	else:
		position.y = 0
