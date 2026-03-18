extends Node2D

const MAIN_MENU_SCENE := "res://ui/MainMenu.tscn"
var back_button: Button

func _ready():
	var scene = get_tree().current_scene

	if scene.scene_file_path == "res://scenes/tutorial.tscn":
		back_button = $CanvasLayer/Control/VBoxContainer3/BackButton
	else:
		back_button = $Control/VBoxContainer3/BackButton

	back_button.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
