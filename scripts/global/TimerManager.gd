extends Node


var elapsed_time: int = 0
var max_time: int = 900  
var timer: Timer
var is_running: bool = false

var alert_target_time: int = 0  
var alert_box: Panel        
var alert_label: Label          

var initialized := false

func setup_once():
	if initialized:
		return
	initialized = true

	_setup_alert_ui()
	_readyrr()



func _readyrr():
	randomize()
	alert_target_time = randi_range(5, 10)

	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1.0  
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	is_running = true
	print("TimerManager: Global timer started - counting up to 15 minutes")
	


	

func _on_timer_timeout():
	elapsed_time += 1
	if elapsed_time == alert_target_time:
		alert_box.visible = true
		print("Alert Triggered at: ", elapsed_time)
	

	if elapsed_time == alert_target_time + 5:
		alert_box.visible = false
		

	if elapsed_time >= max_time:
		timer.stop()
		is_running = false
		print("TimerManager: Timer reached 15 minutes - timer stopped")

func get_elapsed_time() -> int: 
	return elapsed_time

func get_formatted_time() -> String: 
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

	var canvas = CanvasLayer.new()
	canvas.layer = 100 
	add_child(canvas)

	var center = CenterContainer.new()
	canvas.add_child(center)
	
	# Create the Background Box
	alert_box = Panel.new()
	alert_box.custom_minimum_size = Vector2(500, 100)
	alert_box.visible = false 
	canvas.add_child(alert_box)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.8, 0.1, 0.1, 0.9)  
	var radius = 20
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	


	alert_box.add_theme_stylebox_override("panel", style)
	

	

	alert_label = Label.new()
	alert_label.text = "⚠️ EMERGENCY: FLOOD WARNING!"
	alert_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	alert_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	alert_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	alert_box.add_child(alert_label)
	WaterManager.start_rise() 
