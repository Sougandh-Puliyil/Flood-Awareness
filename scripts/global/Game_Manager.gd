extends Node
var 
# The variable tracking currently held 'correct' items
var right_item_count: int = 0

# The "Master List" of what counts as a correct item
var required_items = ["Emergency Kit", "Flashlight", "Water Bottle"]

# --- 1. FUNCTION FOR ADDING ---
func collect_item(item_name: String):
	if item_name in required_items:
		right_item_count += 1
		print("Correct item ADDED! Total correct items: ", right_item_count)
		
		# Check for victory/objective completion
		_check_objective_status()
	else:
		print("Picked up a non-essential item: ", item_name)

# --- 2. FUNCTION FOR REMOVING ---
func remove_item(item_name: String):
	if item_name in required_items:
		# Ensure we don't go below 0 (safety check)
		right_item_count = max(0, right_item_count - 1)
		print("Correct item REMOVED! Total correct items: ", right_item_count)
		
		# Check status again (in case they no longer meet the requirement)
		_check_objective_status()
	else:
		print("Removed a non-essential item: ", item_name)

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
		get_node("/root/Global_Logic").record_event("Torch On at Balcony", "Safe Arrival Set to: " + formatted_rescue_time)
	
	print("Torch Activated. Safe Arrival recorded as: ", formatted_rescue_time)

# Helper function to turn seconds into MM:SS
func _format_seconds(total_seconds: int) -> String:
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	return "%02d:%02d" % [minutes, seconds]
