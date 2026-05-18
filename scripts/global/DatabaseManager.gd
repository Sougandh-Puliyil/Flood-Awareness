extends Node

var db

func _ready():
	db = SQLite.new()
	db.path = "res://data/floodguard-2D.db"
	db.open_db()

func username_exists(username: String) -> bool:
	var query = "SELECT userName FROM Users WHERE userName = ?;"
	db.query_with_bindings(query, [username])
	return db.query_result.size() > 0

func add_user(username: String):
	var query = "INSERT INTO Users (username) VALUES (?);"
	db.query_with_bindings(query, [username])
	
# Saving score into the database
func save_score(username: String, score: float):
	# get the current real-world time for the Timestamp column
	var timestamp = Time.get_datetime_string_from_system()
	
	# use a subquery to find the user_id based on the userName
	var query = "INSERT INTO score_records (user_id, Score, Timestamp) 
	             VALUES ((SELECT user_id FROM Users WHERE userName = ?), ?, ?);"
	
	var bindings = [username, score, timestamp]
	
	db.query_with_bindings(query, bindings)
	print("Database: Saved score %f for user %s" % [score, username])

func get_user_history(username: String):
	# Scoreboard to show a user's past attempts
	var query = "SELECT Score, Timestamp FROM score_records 
	             WHERE user_id = (SELECT user_id FROM Users WHERE userName = ?) 
	             ORDER BY Timestamp DESC
				 LIMIT 5;"
	if db.query_result.size() <1:
		return db.select_rows(query, [username])

func get_user_score(username: String) -> float:
	var score = 0.0
	var query = "SELECT s.Score FROM score_records s " + \
				"JOIN Users u ON s.user_id = u.user_id " + \
				"WHERE u.userName = '" + username + "' " + \
				"ORDER BY s.Timestamp DESC LIMIT 1"
	
	db.query(query)
	
	if db.query_result.size() > 0:
		score = db.query_result[0]["Score"]
		print("DB: Fetched score for ", username, ": ", score)
	else:
		print("DB: No score found for ", username)
		
	return score

func get_highest_score(username: String) -> float:
	var high_score: float = 0.0
	
	# SQL Query: Join tables to find the MAX score associated with the specific username
	var query = """
		SELECT MAX(s.Score) as max_score 
		FROM score_records s
		JOIN Users u ON s.user_id = u.user_id
		WHERE u.userName = ?
	"""

	var result = db.query_with_bindings(query, [username])
	
	if result and db.query_result.size() > 0:
		var row = db.query_result[0]
		# Handle cases where the user exists but has no score records (returns null)
		if row["max_score"] != null:
			high_score = float(row["max_score"])
	
	return high_score
