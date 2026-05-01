extends Node
class_name PathFinder

@onready var min_heap: MinHeap = MinHeap.new()
@export var enable_diagonals: bool = false

func find_path_as_directions(start_pos: Vector2i, end_pos: Vector2i, 
		room_details: RoomDetails) -> Array[Vector2i]:
	var path: = find_path(start_pos, end_pos, room_details)
	var directions: Array[Vector2i] = []
	var prev: = start_pos
	for node in path:
		directions.push_back(node - prev)
		prev = node
	return directions

func find_path(start_pos: Vector2i, end_pos: Vector2i, room_details: RoomDetails) -> Array[Vector2i]:
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
		
		var neighbors_pos: = _get_neighbors_pos(current_node.position, room_details)
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
func _get_neighbors_pos(current_pos: Vector2i, room_details: RoomDetails) -> Array[Vector2i]:
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
		if not _position_in_bounds(neighbor_pos, room_details):
			continue
		if _is_wall(room_details, neighbor_pos):
			continue
		
		neighbors.push_back(neighbor_pos)
	
	return neighbors

#TODO: Add support for locked doors
func _is_wall(details: RoomDetails, pos: Vector2i) -> bool:
	return details.room_layout[pos.y][pos.x] != 0

func _position_in_bounds(pos: Vector2i, room_details: RoomDetails) -> bool:
	if room_details.room_layout.size() == 0:
		return false
	if room_details.room_layout.front().size() == 0:
		return false
	
	if pos.y < 0 or pos.y >= room_details.room_layout.size():
		return false
	if pos.x < 0 or pos.x >= room_details.room_layout.front().size():
		return false
	
	return true
