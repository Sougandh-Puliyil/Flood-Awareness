extends Control

@onready var volume_slider = $VolumeSlider

func _ready():
	volume_slider.connect("value_changed", _on_volume_changed)

func _on_volume_changed(value):
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
