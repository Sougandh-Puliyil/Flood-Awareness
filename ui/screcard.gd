extends Node2D

@onready var score_list = $VBoxContainer/scorelist
@onready var highest_score = $VBoxContainer/highestScore

func _ready():
	#display_scores()
	var high_score = DatabaseManager.get_highest_score(Global_Logic.player_username)
	var recent_scores = DatabaseManager.get_user_history(Global_Logic.player_username)
	# Update Labels
	highest_score.text = str(high_score)
	score_list.text = str(recent_scores)
