extends Node

# --- Foundation Variables ---
# Timer is now managed by TimerManager autoload
var water_level: float = 0.0 #(Scale of 0.0 to 1.0)

# --- State Variables ---
var is_power_on: bool = true #(Changed when Member 2 interacts with the switch)
var has_emergency_kit: bool = false #(Changed when Member 2 picks up the bag)
var player_location: String = "Inside House"


var session_log: Array = []
func record_event(action_name: String, safety_impact: String):
	var new_entry = {
		"time": TimerManager.get_formatted_time(), # Get time from TimerManager
		"action": action_name,
		"impact": safety_impact
	}
	session_log.append(new_entry)
	print("Event Logged: ", new_entry)
	
# --- Multipliers (Task: Speed/Hazard System) ---
var speed_multiplier: float = 1.0
var hazard_risk: float = 0.0
