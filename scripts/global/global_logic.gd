extends Node
var water_level: float = 0.0

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

	current_water_height = 0.0
	water_level = 0.0
	water_current_speed = 0.0
	

	game_over_triggered = false
	player_reached_upper_floor = false
	

	session_log.clear()
	

	if TimerManager.alert_box:
		TimerManager.alert_box.visible = false 
	

	if has_meta("flood_started"):
		remove_meta("flood_started")
		

	TimerManager.stop_timer() 

	TimerManager.reset_timer()
	print("Global Logic: Game state has been fully reset for a new player.")

var max_height: float = -336  
var total_time_ground_fill: float = 40    
var flood_start_time: float = 20.0 
var current_water_height: float = 0.0 
var game_over_triggered: bool = false
var player_reached_upper_floor: bool = false


var flood_stage: int = 1 
var upper_floor_delay: float = 7.0 
var upper_floor_start_time: float = 0.0 
var balcony_reached: bool = false 


var water_current_speed: float = 0.0

func _process(delta):
	var elapsed = TimerManager.get_elapsed_time()
	_check_upper_floor_status()

	if flood_stage == 1:
		_handle_flood_physics(elapsed, flood_start_time, delta)
		

		if player_reached_upper_floor:
			_transition_to_upper_floor(elapsed)
			return 
			

		if current_water_height <= max_height and not player_reached_upper_floor:
			trigger_game_over("Ground floor submerged!")


	elif flood_stage == 2:
		var active_rise_time = upper_floor_start_time + upper_floor_delay
		
		if elapsed >= active_rise_time:
			_handle_flood_physics(elapsed, active_rise_time, delta)
			

			if current_water_height <= max_height and not balcony_reached:
				trigger_game_over("Upper floor submerged!")
		else:
			water_current_speed = 0.0 

# ---------------- Helper Function ---------------
func get_collected_items_text():
	var text = ""

	for i in session_log:
		text += i["time"] + " - " + i["action"] + "\n"

	return text

func _transition_to_upper_floor(time_now: float):
	flood_stage = 2
	upper_floor_start_time = time_now
	current_water_height = 0.0 
	record_event(Game_Manager._format_seconds(time_now), "Upper Floor Ingress", "Stage 2 started")

func _handle_flood_physics(elapsed: float, start_time: float, delta: float):
	if elapsed >= start_time and not game_over_triggered:
		var t = elapsed - start_time
		var power_factor = 1.4
		water_current_speed = (max_height * power_factor / total_time_ground_fill) * pow(t / total_time_ground_fill, power_factor - 1.0)
		current_water_height += water_current_speed * delta
		var normalized = abs(current_water_height / max_height)
		WaterManager.water_progress = clamp(normalized, 0.0, 1.0)

func trigger_game_over(reason: String = ""):
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		p.stop_move()
	if game_over_triggered:
		return
	game_over_triggered = true
	

	TimerManager.stop_timer()
	

	var panel_style = TimerManager.alert_box.get_theme_stylebox("panel") as StyleBoxFlat
	if panel_style:
		panel_style.bg_color = Color(0.15, 0.15, 0.15, 0.95) 
	
	if reason != "":
		TimerManager.alert_label.text = "🚨 GAME OVER 🚨\n\n" + reason 
	else:
		TimerManager.alert_label.text = "🚨 EVACUATION FAILED 🚨\n\nWater levels reached critical height."
	
	TimerManager.alert_box.visible = true
	

	if has_node("/root/Game_Manager"):
		get_node("/root/Game_Manager").calculate_metrics()
	
	
	print("Game Over triggered. Redirecting in 4 seconds...")


	await get_tree().create_timer(4.0).timeout
	

	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
func _check_upper_floor_status():
	var upper_floor_scene_names = [
		"UpperFloor",
		"Bedroom3",
		"Bedroom4",
		"Balcony",
        "Upper_Bathroom"
	]


	player_reached_upper_floor = false

	var current_scene = get_tree().current_scene
	if current_scene:
		player_reached_upper_floor = current_scene.name in upper_floor_scene_names
