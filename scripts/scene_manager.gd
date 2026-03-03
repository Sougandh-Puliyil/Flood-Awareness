extends Node

var scenes: Dictionary={
	"bedroom3":"res://scenes/bedroom3.tscn",
	"bedroom4":"res://scenes/bedroom4.tscn",
	"upper_bathroom":"res://scenes/upper_Bathroom.tscn",
	"balcony":"res://scenes/balcony.tscn",
	"upperFloor":"res://scenes/upperFloor.tscn",
	"kitchen":"res://scenes/kitchen.tscn",
	"bedroom1":"res://scenes/Ground_Bedroom_1.tscn",
	"bedroom2":"res://scenes/Ground_Bedroom_2.tscn",
	#"outdoor":"NOT DEFINED YET"
}

# helper: search for a node entry case-insensitively
func _find_entry_node(root: Node, name: String) -> Node:
	# first try the normal lookup
	var node = root.find_child(name, true, false)
	if node:
		return node
	# fall back to recursive case-insensitive search
	var lower_name = name.to_lower()
	return _search_node_case_insensitive(root, lower_name)

func _search_node_case_insensitive(node: Node, lower_name: String) -> Node:
	var node_name_lower = node.name.to_lower()
	# exact match first
	if node_name_lower == lower_name:
		return node
	# allow substring/endswith (useful when names have prefixes like "bedroomD3" vs "bedD3")
	if node_name_lower.ends_with(lower_name) or node_name_lower.find(lower_name) != -1:
		return node
	for child in node.get_children():
		var found = _search_node_case_insensitive(child, lower_name)
		if found:
			return found
	return null
func transition_to_scene(room:String):
	var scene_path: String = scenes.get(room)

	if scene_path != null:
		await get_tree().create_timer(0.25).timeout
		get_tree().change_scene_to_file(scene_path)

		# Wait multiple frames to ensure the new scene is fully loaded and initialized
		await get_tree().process_frame
		await get_tree().process_frame


		if next_entry_name != "":
			var root = get_tree().get_current_scene()
			if root:
				var entry = _find_entry_node(root, next_entry_name)
				# Try to find Player in the scene, or as an autoload
				var player = root.find_child("Player", true, false)
				if not player:
					player = get_tree().get_root().find_child("Player", false, false)
				
				if player and entry:
					# Temporarily disable collision detection on nearby doors to prevent re-triggering
					var doors_to_disable = []
					var entry_parent = entry.get_parent()
					
					# Disable the entry's parent/door
					if entry_parent and entry_parent is Area2D:
						doors_to_disable.append(entry_parent)
						entry_parent.input_pickable = false
					
					# Also disable the entry itself if it's an Area2D
					if entry is Area2D:
						doors_to_disable.append(entry)
						entry.input_pickable = false
					
					# Get the target position and teleport
					var target_pos = entry.global_position
					player.call_deferred("teleport", target_pos)
					print("SceneManager: Player teleported to %s at position %s" % [next_entry_name, target_pos])
					
					# Re-enable collision after a brief delay
					await get_tree().create_timer(0.15).timeout
					for door in doors_to_disable:
						if is_instance_valid(door):
							door.input_pickable = true
				else:
					if not entry:
						push_error("SceneManager: entry '%s' not found in scene '%s' (case-insensitive search used)" % [next_entry_name, root.name])
						# debug: print names of all children so user can spot mismatches
						var names = []
						for child in root.get_children():
							names.append(child.name)
						print("SceneManager: available top-level nodes: ", names)
					elif not player:
						push_error("SceneManager: Player node not found when trying to teleport to '%s'" % next_entry_name)
				# clear entry name regardless of result
				next_entry_name = ""

# Name of the entry point in the destination scene where the player should appear.
var next_entry_name: String = ""
