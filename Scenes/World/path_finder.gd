extends Node
class_name PathFinder

@onready var min_heap: MinHeap = MinHeap.new()
@onready var jani: Jani = get_parent()
@export var enable_diagonals: bool = false

func initialize() -> void:
	min_heap = MinHeap.new()

func find_path_as_directions(end_pos: Vector2i,
		allow_neighbor_if_unpassable: bool = false) -> Array[Vector2i]:
	
	var path: = find_path(jani.grid_position, end_pos, jani.memory)
	if path.is_empty() and allow_neighbor_if_unpassable:
		# Get neighbors
		var neighbors: = _get_neighboring_pos(end_pos)
		var min_len: int = -1
		for neighbor in neighbors:
			var neighbor_path: = find_path(jani.grid_position, neighbor, jani.memory)
			if neighbor_path.size() > 0 and (min_len < 0 or neighbor_path.size() < min_len):
				path = neighbor_path
				min_len = neighbor_path.size()
		
	var directions: Array[Vector2i] = []
	
	var prev: Vector2i = jani.grid_position
	for node in path:
		directions.push_back(node - prev)
		prev = node
	return directions

func _get_neighboring_pos(pos: Vector2i) -> Array[Vector2i]:
	var left: = Vector2i(pos.x - 1, pos.y)
	var right: = Vector2i(pos.x + 1, pos.y)
	var up: = Vector2i(pos.x, pos.y - 1)
	var down: = Vector2i(pos.x, pos.y + 1)
	
	return [left, right, up, down]

func find_path(start_pos: Vector2i, end_pos: Vector2i, memory: JaniMemory) -> Array[Vector2i]:
	min_heap = MinHeap.new()
	var path: Array[Vector2i] = []
	var start_node: = _create_a_star_node(start_pos, 0, end_pos)
	var g_scores: Dictionary[Vector2i, float] = {}
	var came_from: Dictionary[Vector2i, Vector2i] = {}
	var closed: Dictionary[Vector2i, bool]= {}
	var found: = false
	min_heap.insert(start_node)
	g_scores[start_pos] = 0.0
	
	while not min_heap.is_empty():
		var current_node: = min_heap.pop_top()
		
		if closed.has(current_node.position):
			continue
		closed[current_node.position] = true
		
		if current_node.position == end_pos:
			found = true
			break
		
		var neighbors_pos: = _get_neighbors_pos(current_node.position, memory)
		for neighbor_pos in neighbors_pos:
			var step_cost: = 1.0
			var dir: = neighbor_pos - current_node.position
			if dir.x != 0 and dir.y != 0:
				step_cost = sqrt(2)
			
			var new_cost = g_scores[current_node.position] + step_cost
			if not g_scores.has(neighbor_pos) or new_cost < g_scores[neighbor_pos]:
				g_scores[neighbor_pos] = new_cost
				came_from[neighbor_pos] = current_node.position
				var neighbor_node: = _create_a_star_node(neighbor_pos, new_cost, end_pos)
				min_heap.insert(neighbor_node)
		
	if not found:
		return []
	var current = end_pos
	while current != start_pos:
		path.push_front(current)
		current = came_from[current]
	path.push_front(start_pos)
	return path

func _heuristic(pos: Vector2i, end_pos: Vector2i) -> int:
	return pos.distance_squared_to(end_pos)

func _create_a_star_node(pos: Vector2i, cost: float, end_pos: Vector2i) -> AStarNode:
	var a_star_node: = AStarNode.new()
	a_star_node.position = pos
	a_star_node.f_score = cost + pos.distance_squared_to(end_pos)
	return a_star_node

# Gets neighbors excluding walls
func _get_neighbors_pos(current_pos: Vector2i, memory: JaniMemory) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	var directions: Array[Vector2i] = [
		Vector2i(0, -1),
		Vector2i(-1, 0),
		Vector2i(1, 0),
		Vector2i(0, 1), 
	]
	
	if enable_diagonals:
		directions.append_array([
			Vector2i(-1, -1), 
			Vector2i(1, -1),
			Vector2i(-1, 1),
			Vector2i(1, 1)
		])
	
	for direction in directions:
		var neighbor_pos: = current_pos + direction
		if not _position_in_bounds(memory, neighbor_pos):
			continue
		if _is_unpassable(memory, neighbor_pos):
			continue
		
		neighbors.push_back(neighbor_pos)
	
	return neighbors

func _is_unpassable(memory: JaniMemory, pos: Vector2i) -> bool:
	if memory.env_layout[pos.y][pos.x] == RoomDetails.TileType.WALL:
		return true
	
	for door_pos in memory.room_details.doors:
		var door: = memory.room_details.doors[door_pos]
		if door.grid_pos == pos and door.is_locked:
			return true
	return false

func _position_in_bounds(memory: JaniMemory, pos: Vector2i) -> bool:
	if memory.env_layout.size() == 0:
		return false
	if memory.env_layout.front().size() == 0:
		return false
	
	if pos.y < 0 or pos.y >= memory.env_layout.size():
		return false
	if pos.x < 0 or pos.x >= memory.env_layout.front().size():
		return false
	
	return true
