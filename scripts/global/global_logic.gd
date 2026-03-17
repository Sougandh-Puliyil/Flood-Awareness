extends Node

# --- Foundation Variables ---
# Timer is now managed by TimerManager autoload
var water_level: float = 0.0 #(Scale of 0.0 to 1.0)

var session_log: Array = []
func record_event(time: String, action_name: String, safety_impact: String):
	var new_entry = {
		"time":time,
		"action": action_name,
		"impact": safety_impact
	}
	session_log.append(new_entry)
	print("Event Logged: ", new_entry)
	
# --- UserName Fetching ---

var player_username: String = "Guest"

func set_username(entered_name: String):
	player_username =entered_name
	print("Backend: Saved username as ", player_username)

# ---Session Clearing while logout
func reset_game_state():
	player_username = "Guest"
	# Reset Floats/Ints
	current_water_height = 0.0
	water_level = 0.0
	water_current_speed = 0.0
	
	# Reset Booleans
	game_over_triggered = false
	player_reached_upper_floor = false
	
	# Reset Arrays
	session_log.clear()
	
	# Reset Meta data 
	if has_meta("flood_started"):
		remove_meta("flood_started")
		
	# Reset the TimerManager (since it's also a singleton)
	TimerManager.stop_timer() 
	# Reset the  'reset' function in TimerManager
	TimerManager.reset_timer()
	print("Global Logic: Game state has been fully reset for a new player.")
# --- Water Level logic ---
# ----- Ground Floor --------
var max_height: float = -336  # Total pixels the water should rise
var total_time_ground_fill: float = 40    # Total duration of the flood in seconds (15s)
var flood_start_time: float = 20.0 # Delay before rising starts
var current_water_height: float = 0.0 
var game_over_triggered: bool = false
var player_reached_upper_floor: bool = false

# ----- Upper Floor --------
var flood_stage: int = 1 # 1 = Ground Floor, 2 = Upper Floor
var upper_floor_delay: float = 7.0 
var upper_floor_start_time: float = 0.0 
var balcony_reached: bool = false # Set to true when torch is lit

# --- State ---
var water_current_speed: float = 0.0

func _process(delta):
	var elapsed = TimerManager.get_elapsed_time()
	
	# --- STAGE 1: GROUND FLOOR ---
	if flood_stage == 1:
		_handle_flood_physics(elapsed, flood_start_time, delta)
		
		# Transition: If player reaches upstairs, switch stages immediately
		if player_reached_upper_floor:
			_transition_to_upper_floor(elapsed)
			return 
			
		# Fail: Water hits ceiling while player is still downstairs
		if current_water_height <= max_height:
			trigger_game_over("Ground floor submerged!")

	# --- STAGE 2: UPPER FLOOR ---
	elif flood_stage == 2:
		var active_rise_time = upper_floor_start_time + upper_floor_delay
		
		if elapsed >= active_rise_time:
			_handle_flood_physics(elapsed, active_rise_time, delta)
			
			# Fail: Water hits ceiling before torch is activated
			if current_water_height <= max_height and not balcony_reached:
				trigger_game_over("Upper floor submerged!")
		else:
			water_current_speed = 0.0 # Wait during the 7s delay

# ---------------- Helper Function ---------------
func get_collected_items_text():
	var text = ""

	for i in session_log:
		text += i["time"] + " - " + i["action"] + "\n"

	return text

func _transition_to_upper_floor(time_now: float):
	flood_stage = 2
	upper_floor_start_time = time_now
	current_water_height = 0.0 # Reset water to floor level for Upper Floor
	record_event(Game_Manager._format_seconds(time_now), "Upper Floor Ingress", "Stage 2 started")

func _handle_flood_physics(elapsed: float, start_time: float, delta: float):
	if elapsed >= start_time and not game_over_triggered:
		var t = elapsed - start_time
		var power_factor = 1.4
		water_current_speed = (max_height * power_factor / total_time_ground_fill) * pow(t / total_time_ground_fill, power_factor - 1.0)
		current_water_height += water_current_speed * delta
# ---- Game Over Trigger Function ----
func trigger_game_over(reason: String = ""):
	if game_over_triggered:
		return
	game_over_triggered = true
	
	# Stop the clock
	TimerManager.stop_timer()
	
	# Configure the Game Over UI via TimerManager
	var panel_style = TimerManager.alert_box.get_theme_stylebox("panel") as StyleBoxFlat
	if panel_style:
		panel_style.bg_color = Color(0.15, 0.15, 0.15, 0.95) # Dark, serious gray/black
	#TimerManager.alert_box.border_color = Color(1, 0, 0) # Red border if you use a NinePatch or similar, otherwise just color
	
	# Update Label Text with a professional Game Over message
	if reason != "":
		TimerManager.alert_label.text = "🚨 GAME OVER 🚨\n\n" + reason + "\nRedirecting..."
	else:
		TimerManager.alert_label.text = "🚨 EVACUATION FAILED 🚨\n\nWater levels reached critical height."
	
	# Make it visible
	TimerManager.set_process(false)
	TimerManager.alert_box.visible = true
	
	print("Game Over triggered. Redirecting in 4 seconds...")

	# Wait for 4 seconds
	await get_tree().create_timer(4.0).timeout
	
	# 4. Redirect to the score/results scene
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	
