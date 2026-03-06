extends Node2D

@onready var rect = $ColorRect
@onready var collision = $StaticBody2D/CollisionShape2D

var rise_speed = 5

func _process(delta):
	if rect.position.y > -rect.size.y:
		rect.position.y -= rise_speed * delta
		collision.position.y = rect.position.y
