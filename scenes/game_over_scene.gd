extends Node2D

func _ready() -> void:
	if TimerManager.alert_box:
		TimerManager.alert_box.visible = false
	if TimerManager.alert_label:
		TimerManager.alert_label.text = ""
		
	# Wait for 3 seconds seamlessly upon entering the Game Over scene
	await get_tree().create_timer(3.0).timeout
	
	# Redirect the player to the feedback card screen
	get_tree().change_scene_to_file("res://ui/feedback_card.tscn")
