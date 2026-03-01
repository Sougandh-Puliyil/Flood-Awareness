extends Node

var scenes: Dictionary={
	"bedroom3":"res://scenes/bedroom3.tscn",
	"bedroom4":"res://scenes/bedroom4.tscn",
	"upper_bathroom":"res://scenes/upper_Bathroom.tscn",
	"balcony":"res://scenes/balcony.tscn",
	"upperFloor":"res://scenes/upperFloor.tscn"
}
func transition_to_scene(room:String):
	var scene_path: String = scenes.get(room)

	if scene_path != null:
		await get_tree().create_timer(0.35).timeout
		get_tree().change_scene_to_file(scene_path)

		# Wait multiple frames to ensure the new scene is fully loaded and initialized
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame

		if next_entry_name != "":
			var root = get_tree().get_current_scene()
			if root:
				var entry = root.find_child(next_entry_name, true, false)
			# Try to find Player in the scene, or as an autoload
				var player = root.find_child("Player", true, false)
				if not player:
					player = get_tree().get_root().find_child("Player", false, false)
				
				if player and entry:
					# Get the target position
					var target_pos = entry.global_position
					# Defer the position set to avoid physics immediately pushing them away
					player.call_deferred("set", "global_position", target_pos)
					print("SceneManager: Player teleported to %s at position %s" % [next_entry_name, target_pos])
				else:
					push_error("SceneManager: couldn't find Player or entry '%s' in scene" % next_entry_name)
			next_entry_name = ""

# Name of the entry point in the destination scene where the player should appear.
var next_entry_name: String = ""
