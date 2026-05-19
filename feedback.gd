extends CanvasLayer

# =========================
# UI References
# =========================
# Using Scene Unique Names (%) for cleaner, decoupled references
@onready var score_label = %ScoreLabel
@onready var risk_label = %RiskLabel
@onready var actions_log = %ActionsLog
@onready var missed_list = %MissedList

# Views
@onready var summary_view = %SummaryView
@onready var detailed_view = %DetailedView

# Buttons
@onready var view_feedback_btn = %ViewFeedbackBtn
@onready var new_game_btn = %NewGameBtn


func _ready():

	# =========================
	# Initialize Logic
	# =========================
	var username = Global_Logic.player_username
	var current_score = DatabaseManager.get_user_score(username)

	# =========================
	# Update UI
	# =========================
	score_label.text = "🛡 SAFETY INDEX : " + str(current_score * 100) + "%"
	risk_label.text = "⚠ RISK LEVEL : " + Game_Manager.risk_level_string

	# Dynamic Colors Based On Score
	if current_score >= 0.8:
		score_label.modulate = Color(0.3, 1.0, 0.4)
	elif current_score >= 0.5:
		score_label.modulate = Color(1.0, 0.8, 0.2)
	else:
		score_label.modulate = Color(1.0, 0.3, 0.3)

	# Risk Color
	match Game_Manager.risk_level_string.to_lower():
		"low":
			risk_label.modulate = Color(0.5, 1, 0.5)
		"medium":
			risk_label.modulate = Color(1, 0.8, 0.2)
		"high":
			risk_label.modulate = Color(1, 0.3, 0.3)
		_:
			risk_label.modulate = Color.WHITE

	# =========================
	# Button Styling
	# =========================
	view_feedback_btn.text = "📑 View Detailed Feedback"
	new_game_btn.text = "🔄 Return To Main Menu"

	# =========================
	# Connect Signals
	# =========================
	view_feedback_btn.pressed.connect(_on_view_feedback_pressed)
	new_game_btn.pressed.connect(_on_new_game_pressed)

	# =========================
	# Generate Report
	# =========================
	var report = Game_Manager.get_item_feedback_report()
	_populate_views(report)

	# Start with detail view hidden
	detailed_view.visible = false

	# Small Fade Animation
	summary_view.modulate.a = 0 
	create_tween().tween_property(summary_view, "modulate:a", 1.0, 0.5)


func _on_view_feedback_pressed():

	# Smooth Toggle
	summary_view.visible = false
	detailed_view.visible = true

	# Button Disable After Open
	view_feedback_btn.disabled = true

	# Fade-in animation
	detailed_view.modulate.a = 0
	create_tween().tween_property(
		detailed_view,
		"modulate:a",
		1.0,
		0.4
	)


func _on_new_game_pressed():

	Global_Logic.state_reset_for_new_game()

	# Hide persistent alert if active
	if TimerManager.alert_box:
		TimerManager.alert_box.visible = false

	get_tree().change_scene_to_file("res://ui/MainMenu.tscn")


func _populate_views(report: Dictionary):

	# =====================================================
	# SUMMARY VIEW
	# =====================================================
	var session_history = Global_Logic.get_collected_items_text()

	var summary_text = ""

	summary_text += "[center]"
	summary_text += "[font_size=28][b]📋 SESSION REPORT[/b][/font_size]\n\n"

	if session_history == "":
		summary_text += "[color=gray][i]No items collected during this session.[/i][/color]"
	else:
		summary_text += "[color=white]" + session_history + "[/color]"

	summary_text += "\n\n"
	summary_text += "[wave amp=20 freq=4][color=#aaaaaa]Stay prepared. Stay safe.[/color][/wave]"
	summary_text += "[/center]"

	actions_log.bbcode_text = summary_text


	# =====================================================
	# DETAILED VIEW
	# =====================================================
	var detail_text = ""

	detail_text += "[center]"
	detail_text += "[font_size=28][b]🧾 DETAILED FEEDBACK[/b][/font_size]\n\n"

	# -------------------------
	# Missed Essentials
	# -------------------------
	detail_text += "[color=yellow][b]⚡ MISSED ESSENTIALS[/b][/color]\n\n"

	if report["missed"].is_empty():
		detail_text += "[color=green]✔ None! Great Job.[/color]\n"
	else:
		for item in report["missed"]:
			detail_text += "• [color=#ffdd66]" + item + "[/color]\n"

	detail_text += "\n"

	# -------------------------
	# Incorrect Choices
	# -------------------------
	detail_text += "[color=red][b]❌ INCORRECT CHOICES[/b][/color]\n\n"

	if report["wrong"].is_empty():
		detail_text += "[color=green]✔ No incorrect choices made.[/color]\n"
	else:
		for item in report["wrong"]:
			detail_text += "• [color=#ff8888]" + item + "[/color]\n"

	detail_text += "\n"
	detail_text += "[color=gray][i]Review these items before your next session.[/i][/color]"
	detail_text += "[/center]"

	missed_list.bbcode_text = detail_text
