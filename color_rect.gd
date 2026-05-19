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

	var progress = WaterManager.ground_progress

	var scene_name = get_tree().current_scene.name
	var upper_floor_scenes = [
		"UpperFloor",
		"Bedroom3",
		"Bedroom4",
		"Balcony",
		"Upper_Bathroom"
	]
	if scene_name in upper_floor_scenes:
		progress = WaterManager.upper_progress
# --- Delay only for upper floor ---
	if scene_name in upper_floor_scenes:

	# Hide flood completely before stage 2 starts
		if Global_Logic.flood_stage != 2:
			visible = false
			return

	# Wait until the delay time finishes
		var elapsed = TimerManager.get_elapsed_time()
		var flood_start = Global_Logic.upper_floor_start_time + Global_Logic.upper_floor_delay

		if elapsed < flood_start:
			visible = false
			return

	# Flood is now active upstairs
		visible = true

	position.y = lerp(start_y, end_y, progress)
