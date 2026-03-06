extends CharacterBody2D

var speed = 50
var stopped = false

@onready var sprite = $Sprite2D

func _physics_process(delta):

	if stopped:
		velocity = Vector2.ZERO
		move_and_slide()
		return


	var direction = Vector2.ZERO

	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	if Input.is_action_pressed("ui_down"):
		direction.y += 1

	if Input.is_action_pressed("ui_left"):
		direction.x -= 1

	if Input.is_action_pressed("ui_right"):
		direction.x += 1


	if direction.length() > 0:
		direction = direction.normalized()
		velocity = direction * speed
		sprite.rotation = direction.angle()
	else:
		velocity = Vector2.ZERO


	move_and_slide()

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body == self:
		stopped = true
