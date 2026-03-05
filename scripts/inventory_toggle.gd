extends CanvasLayer
var is_open := false
var inventory_ui = null   # will be assigned automatically

func register_inventory(ui):
	inventory_ui = ui
func _ready():
	hide()

func _input(event):
	if event.is_action_pressed("open_inventory"):
		toggle_inventory()

func toggle_inventory():
	is_open = !is_open

	if is_open:
		show()

		if inventory_ui:
			inventory_ui.update_inventory()
	else:
		hide()
