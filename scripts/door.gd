extends Area2D

@export var room_name: String = ""
@export var entry_name: String = "" # name of matching entry node in destination scene

func _input_event(_viewport, event, _shape_idx):
	# Detection for Tapping/Clicking
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if room_name != "":
			if entry_name != "":
				SceneManager.next_entry_name = entry_name
			SceneManager.transition_to_scene(room_name)
		else:
			push_error("Door Error: You forgot to set a room_name in the Inspector!")

func _on_body_entered(body):
	# Detection for walking into the door
	if body.name == "Player":
		if room_name != "":
			if entry_name != "":
				SceneManager.next_entry_name = entry_name
			SceneManager.transition_to_scene(room_name)
		else:
			push_error("Door Error: You forgot to set a room_name in the Inspector!")
