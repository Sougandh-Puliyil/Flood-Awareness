extends Node2D

const MAIN_MENU_SCENE := "res://ui/MainMenu.tscn"

@onready var back_button: Button = $CanvasLayer/Control/VBoxContainer3/BackButton

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
