extends Control

# References to UI nodes
@onready var score_label = $Panel/VBoxContainer/ScoreLabel
@onready var risk_label = $Panel/VBoxContainer/RiskLabel
@onready var feedback_text = $Panel/VBoxContainer/FeedbackDetails
@onready var main_menu_button = $Panel/NewGameButton 
func _ready():
	# Fetch the data from the DB for the current user
	var username = Global_Logic.player_username
	var score_val = DatabaseManager.get_user_score(username)
	# Connect the signal via code (cleaner than using the Node tab)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	
	# Update the Score and Risk Labels
	score_label.text = "Safety Index: " + str(score_val * 100) + "%"
	risk_label.text = "Risk Level: " + Game_Manager.risk_level_string
	
	# Get the Item Feedback Report
	var report = Game_Manager.get_item_feedback_report()
	_populate_feedback_lists(report)

func _on_main_menu_pressed():
	# CRITICAL: Clear the global data: This resets water levels, logs, and username to "Guest"
	Global_Logic.reset_game_state()
	
	# Hide any lingering Alert Boxes (the Red Evacuation popup)
	if TimerManager.alert_box:
		TimerManager.alert_box.visible = false
	
	# Change the scene to your Main Menu
	get_tree().change_scene_to_file("res://ui/MainMenu.tscn")
	
	print("Game State Reset. Redirecting to Main Menu...")
# ------- Helper Function  --------------
func _populate_feedback_lists(report: Dictionary):
	var text = ""
	
	# Format Correct Items
	text += "[color=green]✔ You selected these correctly:[/color]\n"
	if report["correct"].is_empty():
		text += "- None\n"
	else:
		for item in report["correct"]:
			text += "- " + item + "\n"
	
	text += "\n"
	
	# Format Missed Items
	text += "[color=yellow]❗ You missed these:[/color]\n"
	if report["missed"].is_empty():
		text += "- None\n"
	else:
		for item in report["missed"]:
			text += "- " + item + "\n"
			
	text += "\n"
	
	# Format Wrong Items
	text += "[color=red]✖ These were incorrect choices:[/color]\n"
	if report["wrong"].is_empty():
		text += "- None\n"
	else:
		for item in report["wrong"]:
			text += "- " + item + "\n"
		
	# Set the RichTextLabel text (ensure bbcode_enabled is ON in the inspector)
	feedback_text.bbcode_text = text
