extends RefCounted
class_name ActionQueue

var _heap: Array = []


func push(value: Action) -> void:
	var node = {
		"value": value,
		"priority": value.priority
	}
	_heap.append(node)
	_heapify_up(_heap.size() - 1)


func pop():
	if _heap.is_empty():
		return null
	
	var root = _heap[0]["value"]
	
	# Move last to root
	_heap[0] = _heap[_heap.size() - 1]
	_heap.pop_back()
	
	if not _heap.is_empty():
		_heapify_down(0)
	
	return root


func peek():
	if _heap.is_empty():
		return null
	return _heap[0]["value"]


func is_empty() -> bool:
	return _heap.is_empty()


func size() -> int:
	return _heap.size()

# -------------------------
# Heap helpers
# -------------------------

func _heapify_up(index: int) -> void:
	while index > 0:
		@warning_ignore("integer_division")
		var parent: = (index - 1) / 2
		
		if _heap[index]["priority"] <= _heap[parent]["priority"]:
			break
		
		_swap(index, parent)
		index = parent


func _heapify_down(index: int) -> void:
	while true:
		var left = index * 2 + 1
		var right = index * 2 + 2
		var largest = index
		
		if left < _heap.size() and _heap[left]["priority"] > _heap[largest]["priority"]:
			largest = left
		
		if right < _heap.size() and _heap[right]["priority"] > _heap[largest]["priority"]:
			largest = right
		
		if largest == index:
			break
		
		_swap(index, largest)
		index = largest


func _swap(i: int, j: int) -> void:
	var temp = _heap[i]
	_heap[i] = _heap[j]
	_heap[j] = temp
