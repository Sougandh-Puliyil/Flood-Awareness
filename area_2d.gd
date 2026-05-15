extends Area2D

func _on_body_entered(body):
	if body.name == "Car":
		body.stopped = true
