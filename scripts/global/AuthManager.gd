extends Node

# ---Sign Up Logic -----
func signup(username: String) -> Dictionary:
	username = username.strip_edges()

	if username == "":
		return {"success": false, "message": "Enter a username"}

	if DatabaseManager.username_exists(username):
		return {"success": false, "message": "Username already taken"}

	DatabaseManager.add_user(username)
	return {"success": true, "message": "Account created"}

# ---Login Logic -----
func login(username: String) -> Dictionary:
	username = username.strip_edges()

	if username == "":
		return {"success": false, "message": "Enter a username"}

	if DatabaseManager.username_exists(username):
		Global_Logic.set_username(username)
		return {"success": true, "message": "Login successful"}

	return {"success": false, "message": "User not found"}

# ---LogOut Logic -----
func logout():
	Global_Logic.reset_game_state()
	return {"success": true, "message": "Logged out successfully"}
