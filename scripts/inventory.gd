extends Node
var collected_items := {}
var items: Array[ItemData] = []
@export var max_slots : int = 7
func add_item(item):

	if items.size() >= max_slots:
		print("Inventory full")
		return false

	items.append(item)

	print("Picked up:", item.item_name)
	print("Inventory now:", items)

	emit_signal("inventory_updated")

	return true 
