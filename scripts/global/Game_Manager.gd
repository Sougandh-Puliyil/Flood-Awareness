extends Node

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
