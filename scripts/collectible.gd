extends Area2D

@export var item: ItemData
@export var item_id: String
func _ready():
	input_pickable = true
	if Inventory.collected_items.has(item_id):
		queue_free()
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			collect()
func collect():
	var added = Inventory.add_item(item)

	if added:
		Inventory.collected_items[item_id] = true
		queue_free()
	else:
		print("Inventory full")
