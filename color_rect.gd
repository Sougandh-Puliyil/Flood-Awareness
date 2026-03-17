extends ColorRect

func _process(delta):
	WaterManager.update_water(delta)

	var screen_h = get_viewport_rect().size.y
	
	var start_y = screen_h
	var end_y = -size.y + 110

	# --- scene-specific fix ---
	var scene_path = get_tree().current_scene.scene_file_path
	
	if scene_path in [
		"res://scenes/Ground_Bathroom_2.tscn",
		"res://scenes/Ground_Bedroom_1.tscn",
		"res://scenes/Ground_Bedroom_2.tscn"
	]:
		start_y -= 45   # start a bit higher
		end_y -= 45     # also stop higher
	elif scene_path in [
		"res://scenes/Ground_Bathroom_1.tscn",
	]:
		start_y -= 50   # start a bit higher
		end_y -= 50     # also stop higher

	position.y = lerp(start_y, end_y, WaterManager.water_progress)
