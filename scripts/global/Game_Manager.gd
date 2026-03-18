extends Node

# The variable tracking currently held 'correct' items
var right_item_count: int = 0

# The "Master List" of what counts as a correct item
var required_items = ["FirstAid", "File", "Food_collectible","torch","Phone","Sanitizer","WaterBottle"]

# --- 1. FUNCTION FOR ADDING ---
func collect_item(item_name: String):
	var collected_time:int =TimerManager.get_elapsed_time()
	var format_collected_time: String =TimerManager.get_formatted_time();
	#print("collected item is"+ item_name)
	if item_name in required_items:
		right_item_count += 1
		
		Global_Logic.record_event(format_collected_time,"Correct item ADDED: " + item_name, "Positive")
		print("Correct item ADDED!", item_name)
		
		# Check for victory/objective completion
		_check_objective_status()
	else:
			print("Picked up a non-essential item: ", item_name)
			Global_Logic.record_event(format_collected_time,"Picked up a non-essential item: "+item_name, "Negative")

# --- 2. FUNCTION FOR REMOVING ---
func remove_item(item_name: String):
	var time_now = TimerManager.get_elapsed_time()
	var formatted_time_now: String=TimerManager.get_formatted_time()
	if item_name in required_items:
		# Ensure we don't go below 0 (safety check)
		right_item_count = max(0, right_item_count - 1)
		Global_Logic.record_event(formatted_time_now, "Correct item REMOVED: " + item_name, "Negative (Item Lost)")
		print("Correct item REMOVED! Total correct items: ", right_item_count)
		
		# Check status again (in case they no longer meet the requirement)
		_check_objective_status()
	else:
		print("Removed a non-essential item: ", item_name)
		Global_Logic.record_event(formatted_time_now, "Removed a non-essential item: " + item_name, "Neutral")

# --- 3. HELPER FOR CHECKING STATUS ---
func _check_objective_status():
	if right_item_count >= required_items.size():
		_on_all_items_collected()
	else:
		# You can add logic here if they lose the 'complete' status
		pass

func _on_all_items_collected():
	print("Objective Status: COMPLETE (All items held)")

func is_objective_complete() -> bool:
	return right_item_count >= required_items.size()
	
#******************************* SOS Noting ************************* 

var rescue_time: int=0 # Stores the formatted time (e.g., "02:15")
var torch_activated_raw_time: int = 0 # Stores the raw seconds for logic checks
var formatted_rescue_time: String= ""
# Call when the torch is turned ON
func record_torch_activation():
	# 1. Get the current time from your TimerManager
	var current_time = TimerManager.get_elapsed_time()
	
	# 2.Note the torch activation time
	torch_activated_raw_time = current_time
	
	# 3. Format it into a readable string for your UI/Logs
	rescue_time = torch_activated_raw_time+15
	formatted_rescue_time= _format_seconds(torch_activated_raw_time)
	
	# 4. Log the event in your session log
	if has_node("/root/Global_Logic"):
		get_node("/root/Global_Logic").record_event(formatted_rescue_time,"Torch On at Balcony", "Safe Arrival Set to: " + formatted_rescue_time)
	
	print("Torch Activated. Safe Arrival recorded as: ", formatted_rescue_time)

# Helper function to turn seconds into MM:SS
func _format_seconds(total_seconds: int) -> String:
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	return "%02d:%02d" % [minutes, seconds]
#***************************** Score Calculation ******************

#ResponseTime = Time when the first collectables taken -time when warning issued
#Exposure Duration (ED)=time spent in flooded area

var response_time: int = 0
var exposure_duration: int = 0
var item_collection_score:float=0.0
var total_safe_item_count:int =7
var norm_rt:float=0
var norm_ed:float=0
var norm_items:float=0
# Final outputs for the Scoreboard
var final_safety_score: float = 0.0
var risk_level_string: String = ""

func calculate_metrics():
	# Finding RT (Response Time)
	response_time = 300
	for entry in Global_Logic.session_log:
		if entry["action"].begins_with("Correct item ADDED") or entry["action"].begins_with("Picked up a non-essential"):
			var first_item_time = _string_to_seconds(entry["time"])
			response_time = clamp (float(first_item_time - TimerManager.alert_target_time),0.0,300.0)
			break # Stop at the first one found

	# Finding ED (Exposure Duration)
	if rescue_time > 20: # 20s is when water starts
		exposure_duration = clamp(float( rescue_time - 20),0.0, 600.0)
	# Finding item_collection_score 
	item_collection_score=float( right_item_count)/float(total_safe_item_count) 
	# NORMALIZATION (Turning raw values into 0.0 to 1.0)
	norm_rt = 1.0 - (response_time / 300.0)
	norm_ed = 1.0 - (exposure_duration / 600.0)
	norm_items = clamp(float(item_collection_score), 0.0, 1.0)
	# Overall Safety Index Calculation 
	final_safety_score = (norm_rt * 0.30) + (norm_items * 0.45) + (norm_ed * 0.25)
	final_safety_score=snapped(final_safety_score,0.01)
	print(final_safety_score)
	# RISK LEVEL MAPPING
	risk_level_string = _map_score_to_risk(final_safety_score)
	# --- SAVE TO DB ---
	DatabaseManager.save_score(Global_Logic.player_username, final_safety_score)
	print("Final Safety Index saved to database.")
	
	print("Final Safety Index: ", final_safety_score * 100, "% (", risk_level_string, ")")

# ************** index to risk mapping *****************
func _map_score_to_risk(score: float) -> String:
	if score >= 0.85: return "Low Risk"
	if score >= 0.60: return "Moderate Risk"
	if score >= 0.40: return "High Risk"
	return "Very High Risk"
	

func _string_to_seconds(time_string: String) -> int:
	var parts = time_string.split(":")
	if parts.size() == 2:
		return (parts[0].to_int() * 60) + parts[1].to_int()
	return 0

# -------------- Feedback Reporting -------------

func get_item_feedback_report() -> Dictionary:
	var correct_picked = []
	var missed_items = []
	var incorrect_items = []
	
	# 1. Identify what was actually picked up vs what is required
	# We look at the session_log for "Correct item ADDED" events
	var actually_held = []
	for entry in Global_Logic.session_log:
		if entry["action"].begins_with("Correct item ADDED"):
			var item = entry["action"].get_slice(": ", 1)
			if not actually_held.has(item):
				actually_held.append(item)
		elif entry["action"].begins_with("Correct item REMOVED"):
			var item = entry["action"].get_slice(": ", 1)
			actually_held.erase(item)
			
	# 2. Categorize items
	for item in required_items:
		if actually_held.has(item):
			correct_picked.append(item)
		else:
			missed_items.append(item)
			
	# 3. Find 'Incorrect' (non-essential) items currently in log
	for entry in Global_Logic.session_log:
		if entry["action"].begins_with("Picked up a non-essential"):
			var item = entry["action"].get_slice(": ", 1)
			if not incorrect_items.has(item):
				incorrect_items.append(item)
	
	return {
		"correct": correct_picked,
		"missed": missed_items,
		"wrong": incorrect_items
	}
