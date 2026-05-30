extends Node2D
class_name Room

@export var composition_map: TileMapLayer
@export var details_map: TileMapDetails
@export var jani: Jani

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

func initialize(details: RoomDetails) -> void:
	composition_map.clear()
	details_map.clear()
	room_details = details
	load_composition_map()
	load_details_map()
	
	for pos in room_details.doors:
		room_details.doors[pos].unlocked.connect(_unlock_door)

func load_composition_map() -> void:
	var wall_positions: = _create_wall_positions()
	for wall_pos in wall_positions:
		composition_map.set_cell(wall_pos, 0, composition_atlas[RoomDetails.TileType.WALL])
	
	composition_map.set_cell(room_details.exit, 0, composition_atlas[RoomDetails.TileType.EXIT])
	
	for pos in room_details.doors:
		var atlas: Vector2i = composition_atlas[RoomDetails.TileType.DOOR]
		composition_map.set_cell(room_details.doors[pos].grid_pos, 0, atlas)
	
	for pos in room_details.traps:
		var trap: = room_details.traps[pos]
		composition_map.set_cell(trap.grid_pos, 0, composition_atlas[RoomDetails.TileType.SPIKE])

func load_details_map() -> void:
	_load_locks()
	_load_containers()
	_load_furnitures()
	
	for pos in room_details.traps:
		var trap: = room_details.traps[pos]
		if not jani.memory.trap_locations.has(pos):
			details_map.set_cell_type(trap.grid_pos, TileMapDetails.DetailType.SPIKE_TRAP)

func _create_wall_positions() -> Array[Vector2i]:
	var wall_positions: Array[Vector2i]
	for y in range(room_details.room_layout.size()):
		for x in range(room_details.room_layout[y].size()):
			if room_details.room_layout[y][x] == 1:
				wall_positions.push_back(Vector2i(x, y))
	return wall_positions

func _load_locks() -> void:
	for pos in room_details.doors:
		var door: = room_details.doors[pos]
		var detail_type: = TileMapDetails.lock_type_to_detail(door.lock_type)
		details_map.set_cell_type(pos,detail_type)
		#details_map.set_cell(door.grid_pos, 0, details_atlas[door.lock_type])

func _load_containers() -> void:
	for pos in room_details.containers:
		var container: = room_details.containers[pos]
		container.opened.connect(_opened_chest)
		var type: = TileMapDetails.DetailType.CONTAINER
		if container.is_opened:
			type = TileMapDetails.DetailType.CONTAINER_OPENED
		details_map.set_cell_type(pos, type)

func _load_furnitures() -> void:
	for pos in room_details.furnitures:
		var type: = TileMapDetails.DetailType.UNKNOWN
		var furniture: = room_details.furnitures[pos]
		match furniture.type:
			FurnitureData.Types.TABLE:
				type = TileMapDetails.DetailType.TABLE
		details_map.set_cell_type(pos, type)

# Connected to doors signal
func _unlock_door(pos: Vector2i) -> void:
	details_map.set_cell_type(pos, TileMapDetails.DetailType.NONE)

func _opened_chest(pos: Vector2i) -> void:
	details_map.set_cell_type(pos, TileMapDetails.DetailType.CONTAINER_OPENED)
