extends Control

@onready var profile_dropdown = %ProfileDropdown
@onready var username_label = %UsernameLabel

func _ready():
	# Update the name dynamically from your Global script or Database
	if Global_Logic.player_username != "":
		username_label.text = Global_Logic.player_username
	else:
		get_tree().change_scene_to_file("res://ui/frontpage.tscn")
	
	# Ensure dropdown is hidden on start
	profile_dropdown.visible = false
	
func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/secondpage.tscn")


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/Scorecard.tscn")
	
func _on_profile_icon_pressed():
	profile_dropdown.visible = !profile_dropdown.visible
	

func _on_logout_pressed():
	print("Logging out user: ", Global_Logic.player_username)
	
	var status = AuthorizationManager.logout()
	if not status.success:
		get_tree().change_scene_to_file("res://ui/frontpage.tscn") 		#  Redirect to Front page scene
