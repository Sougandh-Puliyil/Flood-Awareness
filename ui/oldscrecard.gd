extends Node2D

@onready var score_list = $VBoxContainer/ScoreList

func _ready():
	display_scores()

func display_scores():
	var scores = load_scores()

	for s in scores:
		var label = Label.new()
		label.text = str(s)
		score_list.add_child(label)

func load_scores():
	var scores = []

	if FileAccess.file_exists("user://scores.save"):
		var file = FileAccess.open("user://scores.save", FileAccess.READ)

		while not file.eof_reached():
			var line = file.get_line()
			if line != "":
				scores.append(int(line))

		file.close()

	return scores
