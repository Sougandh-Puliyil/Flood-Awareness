extends Area2D

@export var item : ItemData
@export var item_id : String

func _ready():
	input_pickable = true
	$Sprite2D.texture = item.icon
	scale = Vector2.ONE

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:

		var added = Inventory.add_item(item)

		if added:
			Inventory.collected_items[item_id] = true
			queue_free()
