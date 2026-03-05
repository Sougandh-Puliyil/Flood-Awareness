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

	for item in Inventory.items:

		var texture_rect = TextureRect.new()
		texture_rect.texture = item.icon

	# ✅ FORCE SLOT SIZE
		texture_rect.custom_minimum_size = Vector2(64, 64)

	# ✅ prevent stretching container
		texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		texture_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	# ✅ scale image properly
		texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

		add_child(texture_rect)
