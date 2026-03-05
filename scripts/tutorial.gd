extends Node2D

const GROUND_LIVING_SCENE := "res://scenes/Ground_Living.tscn"

@onready var back_button: Button = $CanvasLayer/Control/VBoxContainer3/BackButton

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(GROUND_LIVING_SCENE)
