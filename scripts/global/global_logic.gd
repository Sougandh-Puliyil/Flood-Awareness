extends Node

var water_level: float = 0.0

# =========================
# Session Log
# =========================

var session_log: Array = []

func record_event(time: String, action_name: String, safety_impact: String):
	var new_entry = {
		"time": time,
		"action": action_name,
		"impact": safety_impact
	}

	session_log.append(new_entry)
	print("Event Logged: ", new_entry)


# =========================
# Username
# =========================

var player_username: String = "Guest"

func set_username(entered_name: String):
	player_username = entered_name
	print("Backend: Saved username as ", player_username)


# =========================
# Flood Variables
# =========================

var max_height: float = -336
var total_time_ground_fill: float = 40
var flood_start_time: float = 20.0

var ground_water_height: float = 0.0
var upper_water_height: float = 0.0

var game_over_triggered: bool = false
var player_reached_upper_floor: bool = false

var flood_stage: int = 1

var upper_floor_delay: float = 7.0
var upper_floor_start_time: float = 0.0

var balcony_reached: bool = false

var water_current_speed: float = 0.0


# =========================
# RESET
# =========================

func reset_game_state():

	player_username = "Guest"

	ground_water_height = 0.0
	upper_water_height = 0.0

	WaterManager.ground_progress = 0.0
	WaterManager.upper_progress = 0.0

	water_level = 0.0
	water_current_speed = 0.0

	flood_stage = 1
	game_over_triggered = false
	player_reached_upper_floor = false
	balcony_reached = false

	session_log.clear()

	if TimerManager.alert_box:
		TimerManager.alert_box.visible = false

	TimerManager.stop_timer()
	TimerManager.reset_timer()
	print("Global Logic: Game state has been fully reset for a new player.")

func state_reset_for_new_game():
	current_water_height = 0.0
	water_level = 0.0
	water_current_speed = 0.0
	
	game_over_triggered = false
	player_reached_upper_floor = false
	
	# These three lines reset the simulation state back to day one / ground floor tracking.
	flood_stage = 1               
	balcony_reached = false       
	upper_floor_start_time = 0.0  
	# ============================
	
	if has_node("/root/WaterManager"):
		WaterManager.water_progress = 0.0
		
	session_log.clear()
	
	if TimerManager.alert_box:
		TimerManager.alert_box.visible = false 
	
	if has_meta("flood_started"):
		remove_meta("flood_started")
		
	TimerManager.stop_timer() 
	TimerManager.reset_timer()
	print("Global Logic: Game state tracking cleared for a matching session rerun.")

func get_collected_items_text():
	var text = "" 
	for i in session_log:
		text += i["time"] + " - " + i["action"] + "\n" 
		return text

#var max_height: float = -336  
#var total_time_ground_fill: float = 40    
#var flood_start_time: float = 20.0 
var current_water_height: float = 0.0 
#var game_over_triggered: bool = false
#var player_reached_upper_floor: bool = false
#print("Global Logic: Game state fully reset.")


# =========================
# MAIN LOOP (FIXED PRIORITY ORDER)
# =========================

func _process(delta):

	var elapsed = TimerManager.get_elapsed_time()

	_check_upper_floor_status()

	# =====================================
	# ALWAYS RUN GROUND FLOOD
	# =====================================

	_handle_ground_flood(elapsed, delta)

	var ground_submerged = ground_water_height <= max_height
	var upper_submerged = upper_water_height <= max_height


	# =====================================
	# GAME OVER PRIORITY SYSTEM
	# =====================================

	# If player is upstairs → ONLY upper flood can kill
	if player_reached_upper_floor:

		if flood_stage == 2 and upper_submerged and not balcony_reached:
			trigger_game_over("Upper floor submerged!")
			return

	# If player is downstairs → ONLY ground flood can kill
	else:

		if ground_submerged:
			trigger_game_over("Ground floor submerged!")
			return


	# =====================================
	# TRANSITION CONDITION
	# =====================================

	if flood_stage == 1:
		if ground_submerged and player_reached_upper_floor:
			_transition_to_upper_floor(elapsed)


	# =====================================
	# UPPER FLOOD
	# =====================================

	if flood_stage == 2:

		var active_rise_time = upper_floor_start_time + upper_floor_delay

		if elapsed >= active_rise_time:
			_handle_upper_flood(elapsed, active_rise_time, delta)


# =========================
# GROUND FLOOD
# =========================

func _handle_ground_flood(elapsed: float, delta: float):

	if elapsed < flood_start_time:
		return

	if game_over_triggered:
		return

	var t = elapsed - flood_start_time
	var power_factor = 1.4

	water_current_speed = (max_height * power_factor / total_time_ground_fill) * pow(t / total_time_ground_fill, power_factor - 1.0)

	ground_water_height += water_current_speed * delta

	WaterManager.ground_progress = clamp(abs(ground_water_height / max_height), 0.0, 1.0)


# =========================
# UPPER FLOOD (INDEPENDENT SPEED)
# =========================

func _handle_upper_flood(elapsed: float, start_time: float, delta: float):

	if game_over_triggered:
		return

	var t = elapsed - start_time
	var upper_speed_factor = 1.25

	water_current_speed = (max_height * upper_speed_factor / total_time_ground_fill) * pow(t / total_time_ground_fill, upper_speed_factor - 1.0)

	upper_water_height += water_current_speed * delta

	WaterManager.upper_progress = clamp(abs(upper_water_height / max_height), 0.0, 1.0)


# =========================
# TRANSITION
# =========================

func _transition_to_upper_floor(time_now: float):

	flood_stage = 2
	upper_floor_start_time = time_now

	record_event(
		Game_Manager._format_seconds(time_now),
		"Upper Floor Ingress",
		"Stage 2 started"
	)


# =========================
# GAME OVER
# =========================

func trigger_game_over(reason: String = ""):

	if game_over_triggered:
		return

	game_over_triggered = true

	for p in get_tree().get_nodes_in_group("player"):
		p.stop_move()

	TimerManager.stop_timer()

	var panel_style = TimerManager.alert_box.get_theme_stylebox("panel") as StyleBoxFlat
	if panel_style:
		panel_style.bg_color = Color(0.15, 0.15, 0.15, 0.95)

	TimerManager.alert_label.text = "🚨 GAME OVER 🚨\n\n" + reason
	TimerManager.alert_box.visible = true

	if has_node("/root/Game_Manager"):
		get_node("/root/Game_Manager").calculate_metrics()

	await get_tree().create_timer(4.0).timeout
	

	get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
func _check_upper_floor_status():

	var current_scene = get_tree().current_scene
	if current_scene == null:
		return

	player_reached_upper_floor = current_scene.name in [
		"Bedroom3",
		"Bedroom4",
		"Upper_Bathroom",
		"Balcony",
		"UpperFloor"
	]
