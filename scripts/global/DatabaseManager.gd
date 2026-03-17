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
