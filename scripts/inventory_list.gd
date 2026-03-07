extends GridContainer
func _ready():
	InventoryToggle.register_inventory(self)
func update_inventory():
	print("Updating inventory UI")

	# clear old UI
	for child in get_children():
		child.queue_free()

	# count label (temporary debug)
	var info = Label.new()
	info.text = str(Inventory.items.size()) + " / " + str(Inventory.max_slots)
	info.add_theme_font_size_override("font_size", 28)
	add_child(info)

	for i in range(Inventory.items.size()):

		var item = Inventory.items[i]

		var slot = Button.new()
		slot.custom_minimum_size = Vector2(64,64)
		slot.flat = true

		var texture_rect = TextureRect.new()
		texture_rect.texture = item.icon
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.anchor_right = 1
		texture_rect.anchor_bottom = 1

		slot.add_child(texture_rect)

		slot.pressed.connect(_on_item_pressed.bind(i))

		add_child(slot)
func _on_item_pressed(index):
	print("CLICKED SLOT", index)

	var player = get_tree().get_first_node_in_group("player")
	print("PLAYER:", player)

	if player:
		Inventory.drop_item(index, player)
