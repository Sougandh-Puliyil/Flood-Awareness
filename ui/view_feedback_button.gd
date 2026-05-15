extends Control

@onready var feedback_button = $CanvasLayer/Control/ViewFeedbackButton

func _ready():
	# Connect the button signal to our function
	feedback_button.pressed.connect(_on_feedback_pressed)
	
	# Start the button as disabled and only enable once dynamic score finishes loading.
	feedback_button.disabled = true

func _on_feedback_pressed():
	print("User requested detailed report. Transitioning...")
	
	# Clean up the Alert Box just in case it's still lingering
	if TimerManager.alert_box:
		TimerManager.alert_box.visible = false
	
	# Redirect to the final Feedback Card
	get_tree().change_scene_to_file("res://ui/feedback_card.tscn")

# This is a 'Signal' to the dynamic score UI, can call from their code when the dynamic display is finished.
func enable_navigation():
	feedback_button.disabled = false
