extends Area2D
@onready var message_label = $"../MessageLabel"
var player_inside := false

func _ready():
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)

func _on_enter(body):
	if body.name == "Player":
		player_inside = true
		show_message("Press T to use torch to call for help")

func _on_exit(body):
	if body.name == "Player":
		player_inside = false
		hide_message()

func _input(event):
	if player_inside and event.is_action_pressed("use_torch"):
		check_torch()
func check_torch():

	if Inventory.has_item("torch"):
	#	GameManager.record_torch_activation()
		show_message("You have been rescued!")
	else:
		show_message("No torch collected. Collect torch.")
	
func show_message(text):
	message_label.text = text
	message_label.visible = true

func hide_message():
	message_label.visible = false
