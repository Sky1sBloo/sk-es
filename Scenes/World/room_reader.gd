extends Node
class_name RoomReader

enum States {
	METADATA = 0,
	LAYOUT = 1,
	END = 2
}

# Default room size used when level JSON omits a layout
const DEFAULT_ROOM_SIZE: Vector2i = Vector2i(17, 11)

func _open_level_file(path: String) -> String:
	var file: = FileAccess.open(path, FileAccess.READ)
	if file == null:
		printerr("No file")
		return ""
	var text: = file.get_as_text()
	file.close()
	return text

func get_level(path: String) -> RoomDetails:
	var text: = _open_level_file(path)
	var json: = JSON.new()
	var error: = json.parse(text)
	if error != OK:
		printerr("JSON parse error: ", json.get_error_message(), "at line", json.get_error_line())
	var data = json.data
	
	var room_details: = RoomDetails.new()
	if data.has("objective"):
		room_details.objective = data["objective"]
	
	var _start_pos: Vector2i = _get_grid_pos(data, "start")
	if _start_pos == Vector2i(-1, -1):
		room_details.init_player_position = null
	else:
		room_details.init_player_position = _start_pos

	var _exit_pos: Vector2i = _get_grid_pos(data, "exit")
	if _exit_pos == Vector2i(-1, -1):
		room_details.exit = null
	else:
		room_details.exit = _exit_pos
	room_details.room_layout = _room_layout(data)
	room_details.doors = _load_doors(data)
	room_details.containers = _load_containers(data)
	room_details.traps = _load_traps(data)
	room_details.furnitures = _load_furniture(data)
	# Optional goals object in level JSON; pass through to RoomDetails
	if data.has("goals"):
		room_details.goals = data["goals"]

	# Optional limits object in level JSON; populate RoomDetails.limits and apply defaults for missing keys
	var default_limits = {
		"wall_limit": -1,
		"door_limit": -1,
		"container_limit": -1,
		"trap_limit": -1,
		"furniture_limit": -1
	}
	room_details.limits = default_limits.duplicate(true)
	if data.has("limits") and typeof(data["limits"]) == TYPE_DICTIONARY:
		for k in data["limits"].keys():
			if room_details.limits.has(k):
				room_details.limits[k] = int(data["limits"][k])
	return room_details


func _get_grid_pos(data: Dictionary, id: String) -> Vector2i:
	if not data.has(id):
		printerr("JSON format error: Theres no id of type: ", id)
		return Vector2i(-1, -1)
	
	var x: int = data[id]["x"]
	var y: int = data[id]["y"]
	if x == null or y == null:
		printerr("JSON format error: There is no specified x or y position")
		return Vector2i(-1, -1)
	
	return Vector2i(x, y)

# Returns 2D array of int containing walls
func _room_layout(data: Dictionary) -> Array:
	# If no layout is provided, create a default empty layout
	if not data.has("layout") or (data.has("layout") and typeof(data["layout"]) == TYPE_ARRAY and data["layout"].size() == 0):
		var default_layout: Array = []
		for y in range(DEFAULT_ROOM_SIZE.y):
			default_layout.push_back([])
			for x in range(DEFAULT_ROOM_SIZE.x):
				default_layout.back().push_back(0)
		return default_layout

	var room_layout: Array = []

	for row in data["layout"]:
		room_layout.push_back([])
		for cell in row:
			var cell_type: int = -1
			if cell == "0":
				cell_type = 0
			elif cell == "1":
				cell_type = 1
			room_layout.back().push_back(cell_type)
	return room_layout

func _load_doors(data: Dictionary) -> Dictionary[Vector2i, DoorsData]:
	if not data.has("doors"):
		return {}
	
	var doors: Dictionary[Vector2i, DoorsData] = {}
	for door in data["doors"]:
		var door_data: = DoorsData.new()
		var x: int = door["x"]
		var y: int = door["y"]
		var lock_type: String = door["lock_type"]
		if x == null or y == null or lock_type == null:
			printerr("JSON format error: Door isn't defined correctly")
			continue
		door_data.initialize(Vector2i(x, y), lock_type)
		doors[door_data.grid_pos] = door_data
	
	return doors

func _load_containers(data: Dictionary) -> Dictionary[Vector2i, ContainerData]:
	if not data.has("containers"):
		return {}
	var containers: Dictionary[Vector2i, ContainerData] = {}
	for container in data["containers"]:
		var container_data: = ContainerData.new()
		var x: int = container["x"]
		var y: int = container["y"]
		var type: String = container["type"]
		var item_type: Array[String] = []
		for item in container["contains"]:
			item_type.append(str(item))
		
		if x == null or y == null or type == null or item_type == null:
			printerr("JSON format error: Container isn't defined correctly")
			continue
		container_data.initialize(Vector2i(x, y), type, item_type)
		containers[container_data.grid_pos] = container_data
	return containers

func _load_furniture(data: Dictionary) -> Dictionary[Vector2i, FurnitureData]:
	if not data.has("furnitures"):
		return {}
	var furnitures: Dictionary[Vector2i, FurnitureData] = {}
	
	for furniture in data["furnitures"]:
		var furniture_data: = FurnitureData.new()
		var x: int = furniture["x"]
		var y: int = furniture["y"]
		
		var type: String = furniture["type"]
		if x == null or y == null or type == null:
			printerr("JSON format error: Furniture isn't defined correctly")
			continue
		furniture_data.initialize(Vector2i(x, y), type)
		furnitures[furniture_data.grid_pos] = furniture_data
	return furnitures

func _load_traps(data: Dictionary) -> Dictionary[Vector2i, TrapData]:
	if not data.has("traps"):
		return {}
	var traps: Dictionary[Vector2i, TrapData] = {}
	for trap in data["traps"]:
		var trap_data: = TrapData.new()
		var x: int = trap["x"]
		var y: int = trap["y"]
		var type: String = trap["type"]
		trap_data.initialize(Vector2i(x, y), type)
		traps[Vector2i(x, y)] = trap_data
	return traps
