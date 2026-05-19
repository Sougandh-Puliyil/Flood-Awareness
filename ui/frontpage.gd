extends Control

# Use the % symbol to find nodes regardless of their position in the tree
@onready var about_popup = %AboutPopup
@onready var info_button = %InfoButton
@onready var close_button = %CloseButton

func _ready():
	# Standard practice: ensure the popup is hidden on launch
	if about_popup:
		about_popup.visible = false
	
	# Since you have signals connected in the .tscn file (at the bottom),
	# you don't strictly need to connect them here via code, 
	# but it's okay to keep if the methods match.

func _on_info_button_pressed() -> void:
	print("Info Button was actually clicked!") # If this doesn't show in output, the signal is broken
	if about_popup:
		about_popup.visible = true


func _on_close_button_pressed() -> void:
	if about_popup:
		about_popup.visible = false
