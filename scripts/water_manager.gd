extends Node

var water_progress := 0.0   # 0 = bottom, 1 = top
var rise_speed := 0.0    # small value now (per second)
var initialized := false
func start_rise():
	rise_speed=1
	await get_tree().create_timer(0.65).timeout
	rise_speed=0.005
func update_water(delta):
	if water_progress < 1.0:
		water_progress += rise_speed * delta
		water_progress = clamp(water_progress, 0.0, 1.0)
