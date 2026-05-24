extends Node2D
class_name Room

@export var composition_map: TileMapLayer
@export var details_map: TileMapLayer
@export var items_map: TileMapLayer

var room_details: RoomDetails

var composition_atlas: Dictionary[RoomDetails.TileType, Vector2i] = {
	RoomDetails.TileType.WALL: Vector2i(0, 0),
	RoomDetails.TileType.DOOR: Vector2i(1, 0),
	RoomDetails.TileType.SPIKE: Vector2i(3, 0),
}

var item_atlas: Dictionary[Inventory.ItemType, Vector2i] = {
	Inventory.ItemType.RED_KEY: Vector2i(1, 2),
	Inventory.ItemType.YELLOW_KEY: Vector2i(2, 2),
	Inventory.ItemType.GREEN_KEY: Vector2i(3, 2)
}

enum DetailType {
	NONE,
	RED_LOCK,
	YELLOW_LOCK,
	GREEN_LOCK,
	BOARDED_DOOR,
	CONTAINER,
	SPIKE_TRAP
}
var details_atlas: Dictionary[DetailType, Vector2i] = {
	DetailType.NONE: Vector2i(14, 7),
	DetailType.RED_LOCK: Vector2i(1, 1),
	DetailType.YELLOW_LOCK: Vector2i(2, 1),
	DetailType.GREEN_LOCK: Vector2i(3, 1),
	DetailType.BOARDED_DOOR: Vector2i(2, 0),
	DetailType.CONTAINER: Vector2i(0, 1),
	DetailType.SPIKE_TRAP: Vector2i(0, 2)
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
		var atlas: Vector2i = composition_atlas[RoomDetails.TileType.DOOR]
		composition_map.set_cell(door.grid_pos, 0, atlas)
	
	for trap in room_details.traps:
		composition_map.set_cell(trap.grid_pos, 0, composition_atlas[RoomDetails.TileType.SPIKE])

func load_details_map() -> void:
	_load_locks()
	_load_containers()
	
	for trap in room_details.traps:
		details_map.set_cell(trap.grid_pos, 0, details_atlas[DetailType.SPIKE_TRAP])

func _create_wall_positions() -> Array[Vector2i]:
	var wall_positions: Array[Vector2i]
	for y in range(room_details.room_layout.size()):
		for x in range(room_details.room_layout[y].size()):
			if room_details.room_layout[y][x] == 1:
				wall_positions.push_back(Vector2i(x, y))
	return wall_positions

func _load_locks() -> void:
	for door in room_details.doors:
		details_map.set_cell(door.grid_pos, 0, details_atlas[door.lock_type])

func _load_containers() -> void:
	for container in room_details.containers:
		details_map.set_cell(container.grid_pos, 0, 
			details_atlas[DetailType.CONTAINER])

# Connected to doors signal
func _unlock_door(pos: Vector2i) -> void:
	details_map.set_cell(pos, 0, details_atlas[DoorsData.LockTypes.NONE])
