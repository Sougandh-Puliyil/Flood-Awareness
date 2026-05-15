extends Label

var float_speed = 2.0
var float_amount = 10.0
var time_passed = 0.0
var start_y

func _ready():
	start_y = position.y

func _process(delta):
	time_passed += delta * float_speed
	position.y = start_y + sin(time_passed) * float_amount
