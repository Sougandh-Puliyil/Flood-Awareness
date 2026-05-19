extends CanvasLayer

# Using Scene Unique Names (%) for cleaner, decoupled references
@onready var score_label = %ScoreLabel
@onready var risk_label = %RiskLabel
@onready var actions_log = %ActionsLog
@onready var missed_list = %MissedList

# View Containers
@onready var summary_view = %SummaryView
@onready var detailed_view = %DetailedView

# Buttons
@onready var view_feedback_btn = %ViewFeedbackBtn
@onready var new_game_btn = %NewGameBtn

func _ready():
	# 1. Initialize logic
	var username = Global_Logic.player_username
	# Using the function we built earlier to get the best score from SQLite
	var current_score = DatabaseManager.get_user_score(username) 
	
	# 2. Update UI text
	score_label.text = "Safety Index: " + str(current_score * 100) + "%"
	risk_label.text = "Risk Level: " + Game_Manager.risk_level_string
	
	# 3. Connect Signals
	view_feedback_btn.pressed.connect(_on_view_feedback_pressed)
	new_game_btn.pressed.connect(_on_new_game_pressed)
	
	# 4. Generate the report content
	var report = Game_Manager.get_item_feedback_report()
	_populate_views(report)

func _on_view_feedback_pressed():
	# Transition logic: Hide summary, show details
	summary_view.visible = false
	detailed_view.visible = true

func _on_new_game_pressed():
	Global_Logic.reset_game_state()
	# Ensure the red alert doesn't stay on screen in the next run
	if TimerManager.alert_box:
		TimerManager.alert_box.visible = false
	get_tree().change_scene_to_file("res://ui/MainMenu.tscn")

func _populate_views(report: Dictionary):
	# View 1: Summary (Actions Taken)
	#var summary_text = "[center][color=gray]Session Logs:[/color]\n"
	#summary_text += "Evacuation sequence triggered at " + str(TimeManager.current_time) + "s\n"
	#summary_text += "Total items collected: " + str(report["correct"].size() + report["wrong"].size()) + "[/center]"
	#actions_log.text = summary_text

	# --- View 1: Summary (Actions Taken)

	var session_history = Global_Logic.get_collected_items_text()
	
	var summary_text = "[center][b]SESSION LOG[/b][/center]\n"
	if session_history == "":
		summary_text += "[center]No items collected during this session.[/center]"
	else:
		summary_text += session_history
		
	%ActionsLog.bbcode_text = summary_text
	
	
	# View 2: Detailed (The Missed Essentials list from your image)
	var detail_text = "[center][color=yellow]MISSED ESSENTIALS:[/color]\n"
	if report["missed"].is_empty():
		detail_text += "None! Great Job."
	else:
		for item in report["missed"]:
			detail_text += "• " + item + "\n"
	
	detail_text += "\n[color=red]INCORRECT CHOICES:[/color]\n"
	for item in report["wrong"]:
		detail_text += "• " + item + "\n"
	
	detail_text += "[/center]"
	missed_list.text = detail_text

#extends CanvasLayer
#
## References to UI nodes
#@onready var score_label = $CenterContainer/MainPanel/MarginContainer/VBox_Master/Header/ScoreLabel
#@onready var risk_label = $CenterContainer/MainPanel/MarginContainer/VBox_Master/Header/RiskLabel
#@onready var feedback_text = $CenterContainer/MainPanel/MarginContainer/VBox_Master/DetailedView/MissedList
#@onready var main_menu_button = $CenterContainer/MainPanel/MarginContainer/VBox_Master/DetailedView/NewGameBtn
#func _ready():
	## Fetch the data from the DB for the current user
	#var username = Global_Logic.player_username
	#var score_val = DatabaseManager.get_user_score(username)
	## Connect the signal via code (cleaner than using the Node tab)
	#main_menu_button.pressed.connect(_on_main_menu_pressed)
	#
	## Update the Score and Risk Labels
	#score_label.text = "Safety Index: " + str(score_val * 100) + "%"
	#risk_label.text = "Risk Level: " + Game_Manager.risk_level_string
	#
	## Get the Item Feedback Report
	#var report = Game_Manager.get_item_feedback_report()
	#_populate_feedback_lists(report)
#
#func _on_main_menu_pressed():
	## CRITICAL: Clear the global data: This resets water levels, logs, and username to "Guest"
	#Global_Logic.reset_game_state()
	#
	## Hide any lingering Alert Boxes (the Red Evacuation popup)
	#if TimerManager.alert_box:
		#TimerManager.alert_box.visible = false
	#
	## Change the scene to your Main Menu
	#get_tree().change_scene_to_file("res://ui/MainMenu.tscn")
	#
	#print("Game State Reset. Redirecting to Main Menu...")
## ------- Helper Function  --------------
#func _populate_feedback_lists(report: Dictionary):
	#var text = ""
	#
	## Format Correct Items
	#text += "[color=green]✔ You selected these correctly:[/color]\n"
	#if report["correct"].is_empty():
		#text += "- None\n"
	#else:
		#for item in report["correct"]:
			#text += "- " + item + "\n"
	#
	#text += "\n"
	#
	## Format Missed Items
	#text += "[color=yellow]❗ You missed these:[/color]\n"
	#if report["missed"].is_empty():
		#text += "- None\n"
	#else:
		#for item in report["missed"]:
			#text += "- " + item + "\n"
			#
	#text += "\n"
	#
	## Format Wrong Items
	#text += "[color=red]✖ These were incorrect choices:[/color]\n"
	#if report["wrong"].is_empty():
		#text += "- None\n"
	#else:
		#for item in report["wrong"]:
			#text += "- " + item + "\n"
		#
	## Set the RichTextLabel text (ensure bbcode_enabled is ON in the inspector)
	#feedback_text.bbcode_text = text
