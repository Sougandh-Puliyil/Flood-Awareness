@tool
extends Node2D

@export var drop_count: int = 70
@export var drop_speed: float = 5.0
@export var drop_angle_deg: float = 8.0
@export var drop_length: float = 12.0
@export var drop_opacity: float = 0.3
@export var drop_color: Color = Color(0.66, 0.78, 0.90, 1.0)

var _drops: Array = []
var _screen_size: Vector2
var _angle_rad: float

class RainDrop:
	var pos: Vector2
	var speed: float

func _ready() -> void:
	_screen_size = get_viewport_rect().size
	_angle_rad = deg_to_rad(drop_angle_deg)
	_spawn_all_drops()

func _spawn_all_drops() -> void:
	_drops.clear()
	for i in range(drop_count):
		var drop = RainDrop.new()
		drop.pos = Vector2(
			randf_range(-50, _screen_size.x + 50),
			randf_range(-_screen_size.y, _screen_size.y)
		)
		drop.speed = randf_range(drop_speed * 0.8, drop_speed * 1.2)
		_drops.append(drop)

func _process(delta: float) -> void:
	var move_x = sin(_angle_rad) * drop_speed
	var move_y = cos(_angle_rad) * drop_speed

	for drop in _drops:
		drop.pos.x += move_x
		drop.pos.y += move_y

		if drop.pos.y > _screen_size.y + 20 or drop.pos.x > _screen_size.x + 50:
			drop.pos.x = randf_range(-50, _screen_size.x)
			drop.pos.y = randf_range(-100, -10)

	queue_redraw()

func _draw() -> void:
	var color = Color(drop_color.r, drop_color.g, drop_color.b, drop_opacity)
	var offset = Vector2(
		sin(_angle_rad) * drop_length,
		cos(_angle_rad) * drop_length
	)
	for drop in _drops:
		draw_line(drop.pos, drop.pos + offset, color, 1.0)
