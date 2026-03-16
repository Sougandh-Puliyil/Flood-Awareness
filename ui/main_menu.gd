extends Control

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/secondpage.tscn")


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/Scorecard.tscn")
