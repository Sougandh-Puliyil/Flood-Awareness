extends Node
# Global Timer Manager - Handles persistent timing across all scenes

var elapsed_time: int = 0
var max_time: int = 10  # 20 minutes in seconds
var timer: Timer
var is_running: bool = false

func _ready():
	# Create and configure the timer
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1.0  # Update every 1 second
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	is_running = true
	print("TimerManager: Global timer started - counting up to 20 minutes")

func _on_timer_timeout():
	elapsed_time += 1
	
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
