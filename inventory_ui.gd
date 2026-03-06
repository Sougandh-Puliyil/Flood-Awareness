extends VBoxContainer

func _process(delta):
	update_inventory()

func update_inventory():
	for child in get_children():
		child.queue_free()

	for item in Inventory.items:
		var label = Label.new()
		label.text = item.item_name
		add_child(label)
