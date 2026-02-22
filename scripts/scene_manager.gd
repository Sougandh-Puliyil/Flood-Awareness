extends Node

var scenes: Dictionary={
	"bedroom3":"res://scenes/bedroom3.tscn",
	"bedroom4":"res://scenes/bedroom4.tscn"
}
func transition_to_scene(room:String):
	var scene_path: String =scenes.get(room)
	
	if scene_path!=null:
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file(scene_path)
