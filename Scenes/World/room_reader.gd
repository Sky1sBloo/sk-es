extends Node
class_name RoomReader

enum States {
	METADATA = 0,
	LAYOUT = 1,
	END = 2
}

func _open_level_file(path: String) -> String:
	var file: = FileAccess.open(path, FileAccess.READ)
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
	room_details.init_player_position = _get_start_pos(data)
	room_details.room_layout = _room_layout(data)
	room_details.doors = _load_doors(data)
	room_details.containers = _load_containers(data)
	return room_details

func _get_start_pos(data: Dictionary) -> Vector2i:
	if not data.has("start"):
		printerr("JSON format error: Theres no start position")
		return Vector2i(-1, -1)
	
	var x: int = data["start"]["x"]
	var y: int = data["start"]["y"]
	if x == null or y == null:
		printerr("JSON format error: There is no specified x or y position")
		return Vector2i(-1, -1)
	
	return Vector2i(x, y)

# Returns 2D array of int containing walls
func _room_layout(data: Dictionary) -> Array:
	if not data.has("layout"):
		printerr("JSON format error: There is no layout")
		return []
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

func _load_doors(data: Dictionary) -> Array[DoorsData]:
	if not data.has("doors"):
		return []
	
	var doors: Array[DoorsData] = []
	for door in data["doors"]:
		var door_data: = DoorsData.new()
		var x: int = door["x"]
		var y: int = door["y"]
		var lock_type: String = door["lock_type"]
		if x == null or y == null or lock_type == null:
			printerr("JSON format error: Door isn't defined correctly")
			continue
		door_data.initialize(Vector2i(x, y), lock_type)
		doors.push_back(door_data)
	
	return doors

func _load_containers(data: Dictionary) -> Array[ContainerData]:
	if not data.has("containers"):
		return []
	var containers: Array[ContainerData] = []
	for container in data["containers"]:
		var container_data: = ContainerData.new()
		var x: int = container["x"]
		var y: int = container["y"]
		var type: String = container["type"]
		var item_type: Array[String] = []
		for item in container["contains"]:
			item_type.append(str(item))
		
		if x == null or y == null or type == null or item_type == null:
			printerr("JSON format error: Door isn't defined correctly")
			continue
		container_data.initialize(Vector2i(x, y), type, item_type)
		containers.push_back(container_data)
	return containers
