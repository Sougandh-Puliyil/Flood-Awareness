extends Button
@onready var line_edit = $"username"
@onready var label = $"status"
func _ready():
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)
	connect("pressed", _on_pressed)


func _on_mouse_entered():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2)

func _on_mouse_exited():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)


func _on_pressed() -> void:
	var entered_text = line_edit.text
	var status = AuthorizationManager.signup(entered_text)
	
	if status.reason == "empty": # User didn’t type anything
		label.text = status.message
	elif not status.success: # Non unique Username
		label.text = status.message
	else:       # Unique User
		get_tree().change_scene_to_file("res://ui/frontpage.tscn")
		
