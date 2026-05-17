extends Node

#Sign Up Logic
func signup(username: String) -> Dictionary:
	username = username.strip_edges()

	if username == "":
		return {"success": false, "reason": "empty", "message": "Please enter a valid username!"}

	if DatabaseManager.username_exists(username):
		return {"success": false, "reason": "duplicate", "message": "Username already exists"}

	DatabaseManager.add_user(username)
	return {"success": true, "reason": "success", "message": "Account created"}

#Login Logic
func login(username: String) -> Dictionary:
	username = username.strip_edges()

	if username == "":
		return {"success": false, "reason": "empty", "message": "Please enter a valid username!"}

	if DatabaseManager.username_exists(username):
		Global_Logic.set_username(username)
		return {"success": true, "reason": "success", "message": "Login successful"}

	return {"success": false, "reason": "absent", "message": "User not found"}

# LogOut Logic 
func logout():
	Global_Logic.reset_game_state()
	return {"success": true, "message": "Logged out successfully"}
