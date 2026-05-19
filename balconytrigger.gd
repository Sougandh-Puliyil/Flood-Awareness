extends Area2D

@onready var message_label = $"../MessageLabel"
@export var popup_rescue: Control
@export var popup_score: Control
@export var player: CharacterBody2D

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
		show_message("🔥 Press [T] to use the Torch\n📡 Call for rescue assistance")


func _on_exit(body):
	if body.name == "Player":
		player_inside = false
		hide_message()


func _input(event):
	if player_inside and event.is_action_pressed("use_torch"):
		check_torch()


func check_torch():

	if Inventory.has_item("torch"):

		show_message("🔥 Torch Activated...\n📶 Sending rescue signal")

		Game_Manager.record_torch_activation()

		disable_player()
		await(get_tree().create_timer(3).timeout)

		hide_message()
		show_rescue_popup()

		await(get_tree().create_timer(3.5).timeout)

		show_score_popup()

	else:
		show_message("❌ No Torch Found\n🧭 Explore the map and collect it first")


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

	popup_rescue.get_node("Panel/Label").text = \
		"🚁 RESCUE SUCCESSFUL 🚁\n\n" + \
		"Emergency team has located you.\n" + \
		"Stay safe survivor!"


func show_score_popup():

	Game_Manager.calculate_metrics()

	popup_score.visible = true
	popup_rescue.visible = false

	var score_text = "🏆 FINAL SAFETY SCORE\n\n"
	score_text += str(Game_Manager.final_safety_score * 100) + "%"

	popup_score.get_node("Panel/ScoreLabel").text = score_text

	var meaning_text = "📊 RISK STATUS\n\n"
	meaning_text += str(Game_Manager.risk_level_string)

	popup_score.get_node("Panel/MeaningLabel").text = meaning_text

	var items_text = "🎒 COLLECTED ITEMS\n\n"
	items_text += Global_Logic.get_collected_items_text()

	popup_score.get_node("Panel/ItemsLabel").text = items_text
