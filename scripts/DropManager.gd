extends Node

var drops := []

func save_drop(item_data, pos, scene_name):
	drops.append({
		"item": item_data,
		"position": pos,
		"scene": scene_name
	})
	print("DROPS SAVED:", drops)
