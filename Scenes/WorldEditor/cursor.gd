extends Area2D
class_name Cursor

@onready var sprite: = $AnimatedSprite2D

var able_to_place: bool = false
var _offset: Vector2

func initialize(offset: Vector2) -> void:
	_offset = offset

func move_to_mouse() -> void:
	var mouse_pos: = get_global_mouse_position()
	var grid_size: = GameConfiguration.GRID_SIZE
	var sprite_offset: = Vector2(16, 16)
	var grid_pos: = (mouse_pos - sprite_offset).snapped(Vector2(grid_size, grid_size))
	if _inside_bounds(grid_pos):
		sprite.play("able")
		sprite.visible = true
		able_to_place = true
	else:
		sprite.play("unable")
		able_to_place = false
		sprite.visible = false
	
	global_position = grid_pos

func move_to_mouse_edit() -> void:
	var mouse_pos: = get_global_mouse_position()
	var grid_size: = GameConfiguration.GRID_SIZE
	var sprite_offset: = Vector2(16, 16)
	var grid_pos: = (mouse_pos - sprite_offset).snapped(Vector2(grid_size, grid_size))
	if not _inside_bounds(grid_pos):
		return
	sprite.play("able")
	sprite.visible = true
	able_to_place = true
	global_position = grid_pos
	

func _inside_bounds(pos: Vector2) -> bool:
	if pos.x < _offset.x:
		return false
	if pos.y < _offset.y:
		return false
	if pos.x > 576:
		return false
	if pos.y > 450:
		return false
	return true
