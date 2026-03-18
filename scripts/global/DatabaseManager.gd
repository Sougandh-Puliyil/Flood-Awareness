extends Node

var db

func _ready():
	db = SQLite.new()
	db.path = "res://data/floodguard-2D.db"
	db.open_db()

func username_exists(username: String) -> bool:
	var query = "SELECT userName FROM Users WHERE userName = ?;"
	var result = db.select_rows(query, [username])
	return result.size() > 0

func add_user(username: String):
	var query = "INSERT INTO Users (username) VALUES (?);"
	db.query_with_bindings(query, [username])
	
# Saving score into the database
func save_score(username: String, score: float):
	# We get the current real-world time for the Timestamp column
	var timestamp = Time.get_datetime_string_from_system()
	
	# 2. We use a subquery to find the user_id based on the userName
	var query = "INSERT INTO score_records (user_id, Score, Timestamp) 
	             VALUES ((SELECT user_id FROM Users WHERE userName = ?), ?, ?);"
	
	var bindings = [username, score, timestamp]
	
	db.query_with_bindings(query, bindings)
	print("Database: Saved score %f for user %s" % [score, username])

func get_user_history(username: String):
	# Useful for your Scoreboard to show a user's past attempts
	var query = "SELECT Score, Timestamp FROM score_records 
	             WHERE user_id = (SELECT user_id FROM Users WHERE userName = ?) 
	             ORDER BY Timestamp DESC
				 LIMIT 5;"
	return db.select_rows(query, [username])
