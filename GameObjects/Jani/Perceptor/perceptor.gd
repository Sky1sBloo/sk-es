extends Node
# Used to search in the room
# To identify what the agent knows and what it doesn't
class_name Perceptor

@export var jani: Jani
@export var memory: JaniMemory

var visited: Array[Vector2i] = []

func percept_room() -> void:
	var result: ScanResult = _scan_room()
	
	for container_pos in result.container_locations:
		if not memory.container_locations.has(container_pos):
			memory.container_locations.push_back(container_pos)
	
	for door_pos in result.door_locations:
		if not memory.locked_door_locations.has(door_pos):
			memory.locked_door_locations.push_back(door_pos)
	
	for locked_cont_pos in result.unopened_container_locations:
		if not memory.unopened_container_locations.has(locked_cont_pos):
			memory.unopened_container_locations.push_back(locked_cont_pos)
	
	for furniture in result.furnitures:
		if not memory.furnitures.has(furniture):
			memory.furnitures.push_back(furniture)
	
	for exit_pos in result.exit_locations:
		if not memory.exit_locations.has(exit_pos):
			memory.exit_locations.push_back(exit_pos)

# Run only once per room
# Returns everything found in room
func _scan_room() -> ScanResult:
	visited = []
	var scan_queue: Array[Vector2i] = []
	scan_queue.push_back(jani.grid_position)
	
	var result: ScanResult = ScanResult.new()
	
	
	while not scan_queue.is_empty():
		var front: Vector2i = scan_queue.pop_front()
		# Top
		var top: = Vector2i(front.x, front.y - 1)
		var bottom: = Vector2i(front.x, front.y + 1)
		var left: = Vector2i(front.x - 1, front.y)
		var right: = Vector2i(front.x + 1, front.y)
		
		if _check_cell(top, result):
			scan_queue.push_back(top)
		if _check_cell(bottom, result):
			scan_queue.push_back(bottom)
		if _check_cell(left, result):
			scan_queue.push_back(left)
		if _check_cell(right, result):
			scan_queue.push_back(right)
	return result

# Returns true if cell is valid to be visited
func _check_cell(grid_pos: Vector2i, scan_result: ScanResult) -> bool:
	if visited.has(grid_pos):
		return false
	visited.push_back(grid_pos)
	if _cell_out_of_bounds(grid_pos):
		return false
	var room_details: = jani.world.room.room_details
	if room_details.room_layout[grid_pos.y][grid_pos.x] == 1:
		return false
	if room_details.exit == grid_pos:
		scan_result.exit_locations.push_back(grid_pos)
	
	var container: = room_details.get_cell_container(grid_pos)
	if container != null:
		scan_result.container_locations.push_back(container.grid_pos)
		if not container.is_opened:
			scan_result.unopened_container_locations.push_back(container.grid_pos)
		return true
	
	var furniture: = room_details.get_cell_furniture(grid_pos)
	if furniture != null:
		scan_result.furnitures.push_back(furniture)
		return true
	
	var door: = room_details.get_cell_door(grid_pos)
	if door != null and door.is_locked:
		scan_result.door_locations.push_back(door.grid_pos)
		return false
	
	return true


func _cell_out_of_bounds(grid_pos: Vector2i) -> bool:
	if grid_pos.y < 0 or grid_pos.x < 0:
		return true
	var room_details: = jani.world.room.room_details
	if room_details.room_layout.size() == 0:
		return true
	
	if grid_pos.y >= room_details.room_layout.size():
		return true
	
	if grid_pos.x >= room_details.room_layout[0].size():
		return true
	return false
