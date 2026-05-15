extends ColorRect
var rise_speed = 5

func _process(delta):
	await get_tree().create_timer(5.0).timeout
	if position.y > -size.y+110:
		position.y -= rise_speed * delta
