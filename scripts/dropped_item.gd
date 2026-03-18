extends Area2D
var player_in_range := false
@export var item : ItemData
@export var item_id : String

func _ready():
	input_pickable = true
	$Sprite2D.texture = item.icon
	scale = Vector2.ONE
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:

		if player_in_range:
			var added = Inventory.add_item(item)
			if added:
				Inventory.collected_items[item_id] = true
				queue_free()
		else:
			print("Too far to pick up")
func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false
