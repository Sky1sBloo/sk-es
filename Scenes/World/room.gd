extends Node2D
class_name Room

@export var composition_map: TileMapLayer
@export var details_map: TileMapLayer

var room_details: RoomDetails

var composition_atlas: Dictionary[RoomDetails.TileType, Vector2i] = {
	RoomDetails.TileType.WALL: Vector2i(0, 0),
	RoomDetails.TileType.DOOR: Vector2i(1, 0),
	RoomDetails.TileType.SPIKE: Vector2i(3, 0),
	RoomDetails.TileType.EXIT: Vector2i(0, 3)
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
	TABLE,
	CONTAINER,
	CONTAINER_OPENED,
	SPIKE_TRAP
}
var details_atlas: Dictionary[DetailType, Vector2i] = {
	DetailType.NONE: Vector2i(14, 7),
	DetailType.RED_LOCK: Vector2i(1, 1),
	DetailType.YELLOW_LOCK: Vector2i(2, 1),
	DetailType.GREEN_LOCK: Vector2i(3, 1),
	DetailType.BOARDED_DOOR: Vector2i(2, 0),
	DetailType.TABLE: Vector2i(4, 0),
	DetailType.CONTAINER: Vector2i(5, 0),
	DetailType.CONTAINER_OPENED: Vector2i(6, 0),
	DetailType.SPIKE_TRAP: Vector2i(0, 2)
}

func initialize(details: RoomDetails) -> void:
	composition_map.clear()
	details_map.clear()
	room_details = details
	load_composition_map()
	load_details_map()
	
	for door in room_details.doors:
		door.unlocked.connect(_unlock_door)

func load_composition_map() -> void:
	var wall_positions: = _create_wall_positions()
	for wall_pos in wall_positions:
		composition_map.set_cell(wall_pos, 0, composition_atlas[RoomDetails.TileType.WALL])
	
	composition_map.set_cell(room_details.exit, 0, composition_atlas[RoomDetails.TileType.EXIT])
	
	for door in room_details.doors:
		var atlas: Vector2i = composition_atlas[RoomDetails.TileType.DOOR]
		composition_map.set_cell(door.grid_pos, 0, atlas)
	
	for trap in room_details.traps:
		composition_map.set_cell(trap.grid_pos, 0, composition_atlas[RoomDetails.TileType.SPIKE])

func load_details_map() -> void:
	_load_locks()
	_load_containers()
	_load_furnitures()
	
	for trap in room_details.traps:
		if not trap.is_triggered:
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
		container.opened.connect(_opened_chest)
		var atlas: = details_atlas[DetailType.CONTAINER]
		if container.is_opened:
			atlas = details_atlas[DetailType.CONTAINER_OPENED]
		details_map.set_cell(container.grid_pos, 0, atlas)

func _load_furnitures() -> void:
	for furniture in room_details.furnitures:
		var atlas: Vector2i = Vector2i(-1, -1)
		match furniture.type:
			FurnitureData.Types.TABLE:
				atlas = details_atlas[DetailType.TABLE]
		details_map.set_cell(furniture.grid_pos, 0, atlas)

# Connected to doors signal
func _unlock_door(pos: Vector2i) -> void:
	details_map.set_cell(pos, 0, details_atlas[DetailType.NONE])

func _opened_chest(pos: Vector2i) -> void:
	details_map.set_cell(pos, 0, details_atlas[DetailType.CONTAINER_OPENED])
