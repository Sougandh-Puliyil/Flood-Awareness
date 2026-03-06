extends ColorRect
var rise_speed = 5

func _process(delta):
	if position.y > -size.y+110:
		position.y -= rise_speed * delta
