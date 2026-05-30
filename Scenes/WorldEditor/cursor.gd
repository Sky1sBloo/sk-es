extends Area2D
class_name Cursor

@onready var sprite: = $AnimatedSprite2D

var able_to_place: bool = false
var _offset: Vector2
var _room_size: Vector2i = Vector2i(17, 11)

func initialize(offset: Vector2, room_size: Vector2i) -> void:
	_offset = offset
	if room_size != null:
		_room_size = room_size

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
	var grid_size: = GameConfiguration.GRID_SIZE
	var local_pos: = pos - _offset
	if local_pos.x < 0 or local_pos.y < 0:
		return false
	var tile_x = int(floor(local_pos.x / grid_size))
	var tile_y = int(floor(local_pos.y / grid_size))
	if tile_x < 0 or tile_y < 0:
		return false
	if tile_x >= _room_size.x or tile_y >= _room_size.y:
		return false
	return true
