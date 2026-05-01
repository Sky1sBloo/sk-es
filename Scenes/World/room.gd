extends Node2D
class_name Room

@export var composition_map: TileMapLayer
@export var details_map: TileMapLayer

var room_details: RoomDetails

var composition_atlas: Dictionary[RoomDetails.TileType, Vector2i] = {
	RoomDetails.TileType.WALL: Vector2i(0, 0),
	RoomDetails.TileType.DOOR: Vector2i(1, 0)
}

var details_atlas: Dictionary[DoorsData.LockTypes, Vector2i] = {
	DoorsData.LockTypes.RED: Vector2i(1, 1),
	DoorsData.LockTypes.YELLOW: Vector2i(2, 1),
	DoorsData.LockTypes.GREEN: Vector2i(3, 1),
	DoorsData.LockTypes.NONE: Vector2i(0, 2)
}

func initialize(details: RoomDetails) -> void:
	composition_map.clear()
	room_details = details
	load_composition_map()
	load_details_map()
	
	for door in room_details.doors:
		door.unlocked.connect(_unlock_door)

func load_composition_map() -> void:
	var wall_positions: = _create_wall_positions()
	for wall_pos in wall_positions:
		composition_map.set_cell(wall_pos, 0, composition_atlas[RoomDetails.TileType.WALL])
	
	for door in room_details.doors:
		composition_map.set_cell(door.grid_pos, 0, composition_atlas[RoomDetails.TileType.DOOR])

func load_details_map() -> void:
	_load_locks()

# Connected to doors signal
func _unlock_door(pos: Vector2i) -> void:
	details_map.set_cell(pos, 0, details_atlas[DoorsData.LockTypes.NONE])

func _load_locks() -> void:
	for door in room_details.doors:
		details_map.set_cell(door.grid_pos, 0, details_atlas[door.lock_type])

func _create_wall_positions() -> Array[Vector2i]:
	var wall_positions: Array[Vector2i]
	for y in range(room_details.room_layout.size()):
		for x in range(room_details.room_layout[y].size()):
			if room_details.room_layout[y][x] == 1:
				wall_positions.push_back(Vector2i(x, y))
	return wall_positions
