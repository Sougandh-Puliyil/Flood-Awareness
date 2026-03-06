extends Node
# Global Timer Manager - Handles persistent timing across all scenes

var elapsed_time: int = 0
var max_time: int = 20  # 20 minutes in seconds
var timer: Timer
var is_running: bool = false

var alert_target_time: int = 0  # Stores the random second the alert will appear
var alert_box: ColorRect        # The visual rectangle
var alert_label: Label          # The text inside the rectangle

func _ready():
	randomize()
	alert_target_time = randi_range(5, 10)
	# Create and configure the timer
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1.0  # Update every 1 second
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	is_running = true
	print("TimerManager: Global timer started - counting up to 15 minutes")
	

#	Calling for Pop up
	_setup_alert_ui()

func _on_timer_timeout():
	elapsed_time += 1
	if elapsed_time == alert_target_time:
		alert_box.visible = true
		print("Alert Triggered at: ", elapsed_time)
	
	# Optional: Hide it after 5 seconds of being visible
	if elapsed_time == alert_target_time + 5:
		alert_box.visible = false
		
	# Stop timer when it reaches 20 minutes
	if elapsed_time >= max_time:
		timer.stop()
		is_running = false
		print("TimerManager: Timer reached 20 minutes - timer stopped")

func get_elapsed_time() -> int: #Returns elapsed time in seconds
	return elapsed_time

func get_formatted_time() -> String: #Returns formatted time as MM:SS
	var minutes = elapsed_time / 60
	var seconds = elapsed_time % 60
	return "%02d:%02d" % [minutes, seconds]

func stop_timer():
	"""Stops the timer"""
	if is_running:
		timer.stop()
		is_running = false
		print("TimerManager: Timer stopped at %s" % get_formatted_time())

func reset_timer():
	"""Resets the timer to 0 and restarts it"""
	elapsed_time = 0
	if timer:
		timer.start()
		is_running = true
		print("TimerManager: Timer reset and restarted")

func is_timer_running() -> bool:
	"""Returns whether the timer is currently running"""
	return is_running

func _setup_alert_ui():
	# CanvasLayer makes the UI stay on top of ALL scenes 
	var canvas = CanvasLayer.new()
	canvas.layer = 100 
	add_child(canvas)

	# Create the Background Box
	alert_box = ColorRect.new()
	alert_box.color = Color(0.8, 0.1, 0.1, 0.9) # Emergency Red
	alert_box.custom_minimum_size = Vector2(500, 100)
	alert_box.pivot_offset = Vector2(500, 100) / 2
	alert_box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	alert_box.visible = false # Keep it hidden until the time comes
	canvas.add_child(alert_box)

	# Create the Label
	alert_label = Label.new()
	alert_label.text = "⚠️ EMERGENCY: FLOOD WARNING!"
	alert_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	alert_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	alert_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	alert_box.add_child(alert_label)
