extends Node
var player = null
var dropped_items := []
@export var dropped_item_scene : PackedScene
signal inventory_updated
var collected_items := {}
var items: Array[ItemData] = []
@export var max_slots : int = 7
func _ready():
	get_tree().node_added.connect(_on_node_added)
func _on_node_added(node):
	if node == get_tree().current_scene:
		call_deferred("restore_drops")
func has_item(id:String) -> bool:
	for item in items:
		if item != null and item.has_method("get"):
			if item.get("item_id") == id:
				return true
	return false
func remove_item(index:int):

	if index < 0 or index >= items.size():
		return
	print("PLAYER:", player)
	print("DROP SCENE:", dropped_item_scene)
	var removed = items[index]
	items.remove_at(index)

	# spawn dropped item
	if dropped_item_scene and player:
		var drop = dropped_item_scene.instantiate()
		drop.item = removed
		drop.item_id = removed.item_name

		get_tree().current_scene.add_child(drop)
		drop.global_position = player.global_position

	emit_signal("inventory_updated")
func add_item(item):

	if items.size() >= max_slots:
		print("Inventory full")
		return false

	items.append(item)

	print("Picked up:", item.item_name)
	print("Inventory now:", items)
	#GameManager.collect_item(item.item_id)
	emit_signal("inventory_updated")

	return true 
func drop_item(index:int, player):
	print("DROP FUNCTION CALLED")
	if index < 0 or index >= items.size():
		return

	var item = items[index]
	items.remove_at(index)
	#GameManager.remove_item(item.item_id)
	print("Dropping:", item.item_name)

	# -------- CREATE COLLECTIBLE --------
	var drop = Area2D.new()

	# attach collectible script
	drop.set_script(load("res://scripts/collectible.gd")) # adjust path if needed

	drop.item = item
	drop.item_id = ""

	# sprite (VISIBLE ITEM)
	var sprite = Sprite2D.new()
	sprite.texture = item.icon
	sprite.scale = item.world_scale
	drop.add_child(sprite)

	# collision (CLICKABLE AREA)
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 20
	collision.shape = shape
	drop.add_child(collision)

	# add to current room
	get_tree().current_scene.add_child(drop)

	# place at player
	drop.global_position = player.global_position
	dropped_items.append({
	"item": item,
	"position": drop.global_position,
	"scene": get_tree().current_scene.name
})
	print("DROPS SAVED:", dropped_items)
	print("Dropped at:", drop.global_position)

	emit_signal("inventory_updated")
func restore_drops():
	var scene_name = get_tree().current_scene.name

	for data in dropped_items:

		if data.scene != scene_name:
			continue

		# recreate SAME collectible you already make
		var drop = Area2D.new()
		drop.set_script(load("res://scripts/collectible.gd"))

		drop.item = data.item
		drop.item_id = ""

		var sprite = Sprite2D.new()
		sprite.texture = data.item.icon
		sprite.scale = data.item.world_scale
		drop.add_child(sprite)

		var collision = CollisionShape2D.new()
		var shape = CircleShape2D.new()
		shape.radius = 20
		collision.shape = shape
		drop.add_child(collision)

		get_tree().current_scene.add_child(drop)
		drop.global_position = data.position
