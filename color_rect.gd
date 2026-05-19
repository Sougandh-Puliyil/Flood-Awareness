extends ColorRect

func _process(delta):
	WaterManager.update_water(delta)

	var screen_h = get_viewport_rect().size.y

	var start_y = screen_h
	var end_y = -size.y + 110

	# Scene path adjustments (ground only visuals)
	var scene_path = get_tree().current_scene.scene_file_path

	if scene_path in [
		"res://scenes/Ground_Bathroom_2.tscn",
		"res://scenes/Ground_Bedroom_1.tscn",
		"res://scenes/Ground_Bedroom_2.tscn"
	]:
		start_y -= 45
		end_y -= 45

	elif scene_path in [
		"res://scenes/Ground_Bathroom_1.tscn"
	]:
		start_y -= 50
		end_y -= 50


	var scene_name = get_tree().current_scene.name

	var upper_floor_scenes = [
		"UpperFloor",
		"Bedroom3",
		"Bedroom4",
		"Balcony",
		"Upper_Bathroom"
	]


	# ==============================
	# IMPORTANT FIX: DEFAULT STATE
	# ==============================
	var progress = WaterManager.ground_progress
	visible = true


	# ==============================
	# LOCK UPPER FLOOR WATER
	# UNTIL STAGE 2 STARTS
	# ==============================
	if scene_name in upper_floor_scenes:

		# HARD BLOCK: no upper flood exists before stage 2
		if Global_Logic.flood_stage != 2:
			progress = 0.0
			visible = false
			return

		# Optional delay before flood starts upstairs
		var elapsed = TimerManager.get_elapsed_time()
		var flood_start = Global_Logic.upper_floor_start_time + Global_Logic.upper_floor_delay

		if elapsed < flood_start:
			progress = 0.0
			visible = false
			return

		# NOW upper flood is active
		progress = WaterManager.upper_progress
		visible = true


	# ==============================
	# APPLY MOVEMENT
	# ==============================
	position.y = lerp(start_y, end_y, progress)
