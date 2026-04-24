class_name MinHeap

var _heap: Array[AStarNode]

func insert(node: AStarNode) -> void:
	_heap.push_back(node)
	var i: = _heap.size() - 1
	while i > 0:
		@warning_ignore("integer_division")
		var parent: int = (i - 1) / 2
		if _heap[i].f_score < _heap[parent].f_score:
			var temp: = _heap[i]
			_heap[i] = _heap[parent]
			_heap[parent] = temp
			i = parent
		else:
			break

func get_top() -> AStarNode:
	if _heap.is_empty():
		return null
	
	return _heap[0]

func pop_top() -> AStarNode:
	if _heap.is_empty():
		return null
	
	var min_value: = _heap[0]
	_heap[0] = _heap.back()
	_heap.pop_back()
	if not _heap.is_empty():
		_heapify_down(0)
	return min_value

func is_empty() -> bool:
	return _heap.is_empty()

func _heapify_down(idx: int) -> void:
	var left_child: = idx * 2 + 1
	var right_child: = idx * 2 + 2
	var smallest: = idx
	
	if left_child < _heap.size() and _heap[left_child].f_score < _heap[smallest].f_score:
		smallest = left_child
	if right_child < _heap.size() and _heap[right_child].f_score < _heap[smallest].f_score:
		smallest = right_child
	if smallest != idx:
		var temp: = _heap[idx]
		_heap[idx] = _heap[smallest]
		_heap[smallest] = temp
		_heapify_down(smallest)
