extends Node2D

@export var label_text: String = "Door"

var player_in_range := false

func _ready():
	$Label.text = label_text
	$Label.visible = false

	# keep label consistent
	$Label.scale = Vector2(1,1)
	$Label.add_theme_font_size_override("font_size", 16)
	$Label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true
		$Label.visible = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false
		$Label.visible = false
