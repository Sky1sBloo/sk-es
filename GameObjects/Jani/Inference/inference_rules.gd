extends Node
class_name Inference

@export var memory: JaniMemory
@export var inventory: Inventory

var new_facts_added: = true

var facts: Dictionary[Fact.Type, Array] = {
	Fact.Type.HAS_ITEM : [],
	Fact.Type.NEED_ITEM : [],
	Fact.Type.ITEM_STORED_AT : [],
	Fact.Type.LOCKED_DOOR_AT : [],
	Fact.Type.UNLOCKABLE_DOOR_AT : [],
	Fact.Type.DOOR_KEY_TYPE_IS : [],
	Fact.Type.UNVISITED_DOOR_AT : [],
	Fact.Type.UNVISITED_CONTAINER_AT: [],
	Fact.Type.GET_OPEN_CONTAINER_AT : [],
	Fact.Type.FOUND_EXIT: []
}

func get_facts_as_str() -> Array[String]:
	var fact_str: Array[String] = []
	for type in facts:
		for fact in facts[type]:
			fact_str.append(Fact.type_to_string(fact.type) + str(fact.args))
	return fact_str

# Used in perception
func load_facts() -> void:
	# Delete facts
	for type in facts:
		facts[type].clear()
	
	load_inventory_facts()
	load_container_facts()
	load_item_facts()
	load_door_facts()
	chain_facts()

func chain_facts() -> void:
	new_facts_added = true
	while new_facts_added:
		new_facts_added = false
		unvisited_door()
		check_item_for_locked_door()

func load_inventory_facts() -> void:
	for item in inventory.contents:
		_create_fact(Fact.Type.HAS_ITEM, [item])

func load_container_facts() -> void:
	for container in memory.unopened_container_locations:
		_create_fact(Fact.Type.UNVISITED_CONTAINER_AT, [container])

func load_item_facts() -> void:
	for item in memory.item_locations:
		_create_fact(Fact.Type.ITEM_STORED_AT, item)

func load_door_facts() -> void:
	for door in memory.locked_door_locations:
		_create_fact(Fact.Type.LOCKED_DOOR_AT, [door])
	
	for pos in memory.door_lock_type:
		_create_fact(Fact.Type.DOOR_KEY_TYPE_IS, [pos, memory.door_lock_type[pos]])
	
	for pos in memory.exit_locations:
		_create_fact(Fact.Type.FOUND_EXIT, [pos])

## Rules
func unvisited_door() -> void:
	for fact in facts[Fact.Type.LOCKED_DOOR_AT]:
		var found: = false
		for lock_type in facts[Fact.Type.DOOR_KEY_TYPE_IS]:
			if lock_type.args[0] == fact.args[0]:
				found = true
				break
		if not found:
			if _create_fact(Fact.Type.UNVISITED_DOOR_AT, [fact.args[0]]):
				new_facts_added = true

func check_item_for_locked_door() -> void:
	for fact in facts[Fact.Type.DOOR_KEY_TYPE_IS]:
		var item_needed: Inventory.ItemType
		match fact.args[1]:
			DoorsData.LockTypes.RED:
				item_needed = Inventory.ItemType.RED_KEY
			DoorsData.LockTypes.GREEN:
				item_needed = Inventory.ItemType.GREEN_KEY
			DoorsData.LockTypes.YELLOW:
				item_needed = Inventory.ItemType.YELLOW_KEY
		if _has_fact(Fact.Type.HAS_ITEM, [item_needed]):
			if _create_fact(Fact.Type.UNLOCKABLE_DOOR_AT, [fact.args[0]]):
				new_facts_added = true
		else:
			if _create_fact(Fact.Type.NEED_ITEM, [item_needed]):
				new_facts_added = true


## Helpers
# Returns if successful
func _create_fact(type: Fact.Type, args: Array) -> bool:
	if _has_fact(type, args):
		return false
	var new_fact: = Fact.new()
	new_fact.initialize(type, args)
	
	facts[type].append(new_fact)
	return true

func _delete_fact(type: Fact.Type, args: Array) -> void:
	var del: Array[Fact] = []
	for fact in facts[type]:
		if fact.args == args:
			del.append(fact)
	
	for fact in del:
		facts[type].erase(fact)

func _find_fact(type: Fact.Type) -> Array:
	return facts[type]

func _fact_exists(fact: Fact) -> bool:
	for f in facts[fact.type]:
		if f.args == fact.args:
			return true
	return false

func _has_fact(type: Fact.Type, args: Array) -> bool:
	for f in facts[type]:
		if f.args == args:
			return true
	return false
