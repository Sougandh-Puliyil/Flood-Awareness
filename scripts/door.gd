extends Area2D

@export var room_name: String = ""
@export var entry_name: String = "" 

var _transition_in_progress: bool = false

func _ready():
	# Ensure the flag is reset when the door scene is loaded
	_transition_in_progress = false

#func _input_event(_viewport, event, _shape_idx):
	## Detection for Tapping/Clicking
	#if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#if not _transition_in_progress and room_name != "":
			#_transition_in_progress = true
			#if entry_name != "":
				#SceneManager.next_entry_name = entry_name
				#print("Setting next_entry_name to: ", SceneManager.next_entry_name)
			#SceneManager.transition_to_scene(room_name)
		#else:
			#if _transition_in_progress:
				#print("Door: Transition already in progress, ignoring input")
			#else:
				#push_error("Door Error: You forgot to set a room_name in the Inspector!")

func _on_body_entered(body):
	# Detection for walking into the door
	if body.name == "Player" and not _transition_in_progress:
		if room_name != "":
			_transition_in_progress = true
			if entry_name != "":
				SceneManager.next_entry_name = entry_name
				print("Setting next_entry_name to: ", SceneManager.next_entry_name)
			SceneManager.transition_to_scene(room_name)
		else:
			push_error("Door Error: You forgot to set a room_name in the Inspector!")
