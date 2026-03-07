extends Node

# --- Foundation Variables ---
# Timer is now managed by TimerManager autoload
var water_level: float = 0.0 #(Scale of 0.0 to 1.0)

# --- State Variables ---
#var is_power_on: bool = true #(Changed when Member 2 interacts with the switch)
#var has_emergency_kit: bool = false #(Changed when Member 2 picks up the bag)
#var player_location: String = "Inside House"


var session_log: Array = []
func record_event(time: String, action_name: String, safety_impact: String):
	var new_entry = {
		"time":time,
		"action": action_name,
		"impact": safety_impact
	}
	session_log.append(new_entry)
	print("Event Logged: ", new_entry)
	#*******************************************************
# --- Multipliers (Task: Speed/Hazard System) ---
var speed_multiplier: float = 1.0
var hazard_risk: float = 0.0

#************************** Water Level logic ************************
var max_height: float = 641.0      # Total pixels the water should rise
var total_time: float = 900     # Total duration of the flood in seconds (15s)
var flood_start_time: float = 20.0 # Delay before rising starts

# --- State ---
var water_current_speed: float = 0.0

func _process(_delta):
	var elapsed = TimerManager.get_elapsed_time()
	
	if elapsed >= flood_start_time:
		# 1. Calculate how much 'active' flood time has passed
		var t = elapsed - flood_start_time
		
		# This ensures the 'Area under the curve' equals your max_height
		var power_factor = 1.4
		
		# Speed Formula: (MaxHeight * Power / TotalTime) * (t / TotalTime)^(Power - 1)
		water_current_speed = (max_height * power_factor / total_time) * pow(t / total_time, power_factor - 1.0)
		
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
