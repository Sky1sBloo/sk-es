class_name RoomDetails

enum TileType {
	EMPTY = 0,
	WALL = 1,
	DOOR = 2,
	SPIKE = 3,
	EXIT = 4,
	JANI = 99
}

var room_layout: Array  # 2D array of int
var objective: String = ""
var init_player_position = null
var exit = null
var doors: Dictionary[Vector2i, DoorsData] = {}
var containers: Dictionary[Vector2i, ContainerData] = {}
var furnitures: Dictionary[Vector2i, FurnitureData] = {}
var traps: Dictionary[Vector2i, TrapData] = {}
var limits: Dictionary = {}
var goals: Dictionary = {}

func get_cell_trap(pos: Vector2i) -> TrapData:
	if traps.has(pos):
		return traps[pos]
	return null

func get_cell_door(pos: Vector2i) -> DoorsData:
	if doors.has(pos):
		return doors[pos]
	return null

func get_cell_container(pos: Vector2i) -> ContainerData:
	if containers.has(pos):
		return containers[pos]
	return null

func get_cell_furniture(pos: Vector2i) -> FurnitureData:
	if furnitures.has(pos):
		return furnitures[pos]
	return null

func clone() -> RoomDetails:
	var copy = RoomDetails.new()
	copy.objective = objective
	copy.init_player_position = init_player_position
	copy.exit = exit
	# --- Room layout (2D array) ---
	copy.room_layout = []
	for row in room_layout:
		copy.room_layout.append(row.duplicate(true))
	# --- Doors (deep copy) ---
	
	for pos in doors:
		if doors[pos] != null:
			copy.doors[pos] = doors[pos].clone()
	# --- Containers (deep copy) ---
	
	for pos in containers:
		if containers[pos] != null:
			copy.containers[pos] = containers[pos].clone()
	# --- Furnitures (deep copy) ---
	
	for pos in furnitures:
		if furnitures[pos] != null:
			copy.furnitures[pos] = furnitures[pos].clone()
	# --- Traps (deep copy) ---
	
	for pos in traps:
		if traps[pos] != null:
			copy.traps[pos] = traps[pos].clone()

	# --- Simple dictionaries ---
	copy.limits = limits.duplicate(true)
	copy.goals = goals.duplicate(true)

	return copy
