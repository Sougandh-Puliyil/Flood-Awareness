extends Button

func _ready():
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)
	pressed.connect(_on_interactive_mode_button_pressed)

func _on_mouse_entered():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2)

func _on_mouse_exited():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
func _on_interactive_mode_button_pressed():
	get_tree().change_scene_to_file("res://scenes/Ground_Living.tscn")
