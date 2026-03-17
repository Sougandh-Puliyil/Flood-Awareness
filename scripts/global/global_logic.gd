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
var max_height: float = -336  # Total pixels the water should rise
var total_time_ground_fill: float = 40    # Total duration of the flood in seconds (15s)
var flood_start_time: float = 20.0 # Delay before rising starts
var current_water_height: float = 0.0 
var game_over_triggered: bool = false
var player_reached_upper_floor: bool = false

# --- State ---
var water_current_speed: float = 0.0

func _process(delta):
	var elapsed = TimerManager.get_elapsed_time()
	
	if elapsed >= flood_start_time and not game_over_triggered:
		# 1. Calculate how much 'active' flood time has passed
		var t = elapsed - flood_start_time
		
		# This ensures the 'Area under the curve' equals your max_height
		var power_factor = 1.4
		
		# Speed Formula: (MaxHeight * Power / TotalTime) * (t / TotalTime)^(Power - 1)
		water_current_speed = (max_height * power_factor / total_time_ground_fill) * pow(t / total_time_ground_fill, power_factor - 1.0)
		
		current_water_height += water_current_speed * delta
				
		# Check if the ground floor fulling filled?
		if current_water_height <= max_height and not player_reached_upper_floor:
			print("Water reached maximum height")
			trigger_game_over()
		# 3. Log the start once
		if not has_meta("flood_started"):
			var time_string = "%02d:%02d" % [int(flood_start_time) / 60, int(flood_start_time) % 60]
			record_event(time_string, "Flood Ingress", "Non-linear water rise initiated")
			set_meta("flood_started", true)
	else:
		water_current_speed = 0.0

func get_collected_items_text():
	var text = ""

	for i in session_log:
		text += i["time"] + " - " + i["action"] + "\n"

	return text
	
# ---- Game Over Trigger Function ----
func trigger_game_over():
	game_over_triggered = true
	
	# Stop the clock
	TimerManager.stop_timer()
	
	# Configure the Game Over UI via TimerManager
	TimerManager.alert_box.color = Color(0.15, 0.15, 0.15, 0.95) # Dark, serious background
	#TimerManager.alert_box.border_color = Color(1, 0, 0) # Red border if you use a NinePatch or similar, otherwise just color
	
	# Update Label Text with a professional Game Over message
	TimerManager.alert_label.text = "🚨 EVACUATION FAILED 🚨\n\nWater levels have reached critical height.\nRedirecting to Results..."
	
	# Make it visible
	TimerManager.set_process(false)
	TimerManager.alert_box.visible = true
	
	print("Game Over triggered. Redirecting in 4 seconds...")

	# Wait for 4 seconds
	await get_tree().create_timer(4.0).timeout
	
	# 4. Redirect to the score/results scene
	get_tree().change_scene_to_file("res://scenes/score.tscn")
	
