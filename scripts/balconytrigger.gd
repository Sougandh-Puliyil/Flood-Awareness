extends Area2D

@onready var message_label = $"../MessageLabel"
@export var popup_rescue: Control
@export var popup_score: Control
@export var player: Node2D         
var player_inside := false

func _ready():
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)
	if popup_rescue:
		popup_rescue.visible = false
	if popup_score:
		popup_score.visible = false
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
		disable_player()
		hide_message()
		await(get_tree().create_timer(3).timeout)
		show_rescue_popup()
		await(get_tree().create_timer(3.5).timeout)  # ~6.5 sec total
		show_score_popup()
	else:
		show_message("No torch collected. Collect torch.")
	
func show_message(text):
	message_label.text = text
	message_label.visible = true

func hide_message():
	message_label.visible = false
func disable_player():
	player.set_process_input(false)  
	player.velocity = Vector2.ZERO   
func show_rescue_popup():
	popup_rescue.visible = true
	popup_rescue.get_node("Panel/Label").text = "You have been rescued!"
func show_score_popup():
	popup_score.visible = true
	#popup_score.get_node("Panel/ScoreLabel").text = str(GameManager.get_score())
	popup_score.get_node("Panel/MeaningLabel").text = "Score meaning goes here"
	popup_score.get_node("Panel/ItemsLabel").text = Inventory.get_collected_items_text()
