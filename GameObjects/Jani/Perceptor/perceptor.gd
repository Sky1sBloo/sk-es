extends Node
# Used to search in the room
# To identify what the agent knows and what it doesn't
class_name Perceptor

@export var jani: Jani
@export var memory: JaniMemory

var visited: Array[Vector2i] = []

func percept_room() -> void:
	var result: ScanResult = _scan_room()

	# Record percepted grid positions into memory (exclude walls)
	for pos in visited:
		var rd := jani.world.room.room_details
		if rd != null and rd.room_layout.size() > 0:
			if pos.y >= 0 and pos.y < rd.room_layout.size() and pos.x >= 0 and pos.x < rd.room_layout[0].size():
				if rd.room_layout[pos.y][pos.x] != 1 and not memory.percepted_positions.has(pos):
					memory.percepted_positions.push_back(pos)
	
	for container_pos in result.container_locations:
		if not memory.container_locations.has(container_pos):
			memory.container_locations.push_back(container_pos)
	
	for door_pos in result.door_locations:
		if _is_useless_locked_door(door_pos):
			continue
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
		# Determine whether this door actually separates unknown space or
		# is just a floating/useless door. If all adjacent tiles are either
		# walls or already percepted, treat it as non-blocking.
		var neighbors: Array = [Vector2i(grid_pos.x, grid_pos.y - 1),
						Vector2i(grid_pos.x, grid_pos.y + 1),
						Vector2i(grid_pos.x - 1, grid_pos.y),
						Vector2i(grid_pos.x + 1, grid_pos.y)]
		var all_seen_or_wall: bool = true
		for n in neighbors:
			if _cell_out_of_bounds(n):
				continue
			# if neighbor is a wall, consider it 'seen'
			if room_details.room_layout[n.y][n.x] == 1:
				continue
			# if neighbor hasn't been visited in this scan and isn't in memory's
			# percepted positions, then the door may lead to unknown space
			if not visited.has(n) and not memory.percepted_positions.has(n):
				all_seen_or_wall = false
				break
		if all_seen_or_wall:
			# don't treat as a blocking locked door
			return true
		# otherwise treat as a locked door (block scanning beyond it)
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


func _is_useless_locked_door(grid_pos: Vector2i) -> bool:
	var rd := jani.world.room.room_details
	if rd == null:
		return false

	var neighbors: Array = [Vector2i(grid_pos.x, grid_pos.y - 1),
						Vector2i(grid_pos.x, grid_pos.y + 1),
						Vector2i(grid_pos.x - 1, grid_pos.y),
						Vector2i(grid_pos.x + 1, grid_pos.y)]
	for n in neighbors:
		if _cell_out_of_bounds(n):
			continue
		# wall counts as 'seen'
		if rd.room_layout[n.y][n.x] == 1:
			continue
		# if neighbor hasn't been percepted previously and wasn't visited this scan,
		# consider the door as potentially leading to unknown space
		if not memory.percepted_positions.has(n) and not visited.has(n):
			return false
	# all neighbors are either walls or known
	return true
