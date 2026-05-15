extends Area2D
var player_in_range := false
var label: Label
@export var item: ItemData
@export var item_id: String
var drop_id = ""
func _ready():
	input_pickable = true
	# apply icon if sprite exists
	if has_node("Sprite2D") and item:
		$Sprite2D.texture = item.icon
	# 🔹 Create label
	label = Label.new()
	label.text = item.item_name if item else "Item"
	label.visible = false

	label.size = Vector2(120, 30)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.clip_text = true

	label.top_level = true   # 🔥 KEY LINE

	var label_holder = Node2D.new()
	label_holder.position = Vector2(-60, -50)

	add_child(label_holder)
	label_holder.add_child(label)
	label.scale = Vector2(1,1)
	
	
	# 🔹 connect signals
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)
	if item_id != "" and Inventory.collected_items.has(item_id):
		queue_free()
		
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:

		if player_in_range:
			collect()
		else:
			print("Too far to pick up")
func collect():
	var added = Inventory.add_item(item)

	if added:
		Inventory.collected_items[item_id] = true
		if drop_id != "":
			for i in range(Inventory.dropped_items.size()):
				if Inventory.dropped_items[i]["id"] == drop_id:
					Inventory.dropped_items.remove_at(i)
					break

		queue_free()
	else:
		print("Inventory full")
func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true
		label.visible = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false
		label.visible = false
