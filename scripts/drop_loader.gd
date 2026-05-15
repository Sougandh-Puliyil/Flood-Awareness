extends Node2D

func _ready():

	var current_scene = get_tree().current_scene.name
	print("Loading drops for:", current_scene)

	for data in Inventory.dropped_items:

		if data.scene != current_scene:
			continue

		print("Respawning:", data.item.item_name)

		var drop = Area2D.new()
		drop.set_script(load("res://collectible.gd"))

		drop.drop_id = data.id
		drop.item_id = data.item.item_id

		var sprite = Sprite2D.new()
		sprite.texture = data.item.icon
		sprite.scale = data.item.world_scale
		drop.add_child(sprite)

		var collision = CollisionShape2D.new()
		var shape = CircleShape2D.new()
		shape.radius = 20
		collision.shape = shape
		drop.add_child(collision)

		add_child(drop)
		drop.global_position = data.position
