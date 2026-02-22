extends Area2D

# This creates the file-picker in your Inspector
#@export_file("*.tscn") var target_scene: String
@export var room_name: String = ""

func _input_event(_viewport, event, _shape_idx):
	# Detection for Tapping/Clicking
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#change_level()
		SceneManager.transition_to_scene(room_name)

func _on_body_entered(body):
	# Detection for walking into the door
	if body.name == "Player":
		#change_level()
		SceneManager.transition_to_scene(room_name)
	else:
		push_error("Door Error: You forgot to set a room_name in the Inspector!")

#func change_level():
	#if target_scene == "":
		#print("Warning: No scene selected!")
	#else:
		#get_tree().change_scene_to_file(target_scene)
#
#func _on_exit_area_2d_body_entered(body: Node2D) -> void:
	#pass # Replace with function body.
#
#
#func _on_exit_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	#pass # Replace with function body.
#
