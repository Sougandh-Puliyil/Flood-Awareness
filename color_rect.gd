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

	var progress = WaterManager.water_progress

	var scene_name = get_tree().current_scene.name
	var upper_floor_scenes = [
		"UpperFloor",
		"Bedroom3",
		"Bedroom4",
		"Balcony",
		"Upper_Bathroom"
	]

# --- Delay only for upper floor ---
	if scene_name in upper_floor_scenes:
		if Global_Logic.flood_stage == 2:
			var delay_factor = 0.3  # tweak this (0.1–0.4 works well)
			progress = clamp((progress - delay_factor) / (1.0 - delay_factor), 0.0, 1.0)
		else:
			progress = 0.0

	position.y = lerp(start_y, end_y, progress)
