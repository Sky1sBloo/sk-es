extends Node
class_name Inference

@export var memory: JaniMemory
@export var inventory: Inventory

var new_facts_added: = true

var facts: Dictionary[Fact.Type, Array] = {
	Fact.Type.HAS_ITEM : [],
	Fact.Type.NEED_ITEM : [],
	Fact.Type.MISSING_CRAFTABLE_ITEM : [],
	Fact.Type.ITEM_STORED_AT : [],
	Fact.Type.ITEM_NEEDED_AT : [],
	Fact.Type.CRAFTABLE_ITEM: [],
	Fact.Type.NEED_CRAFT: [],
	Fact.Type.LOCKED_DOOR_AT : [],
	Fact.Type.UNLOCKABLE_DOOR_AT : [],
	Fact.Type.DOOR_KEY_TYPE_IS : [],
	Fact.Type.UNVISITED_DOOR_AT : [],
	Fact.Type.UNVISITED_CONTAINER_AT: [],
	Fact.Type.GET_OPEN_CONTAINER_AT : [],
	Fact.Type.FURNITURE_AT : [],
	Fact.Type.FOUND_EXIT: []
}

func get_facts_as_str() -> Array[String]:
	var fact_str: Array[String] = []
	for type in facts:
		for fact in facts[type]:
			fact_str.append(fact.fact_to_string())
	return fact_str

# Used in perception
func load_facts() -> void:
	# Delete facts
	for type in facts:
		facts[type].clear()
	
	load_inventory_facts()
	load_container_facts()
	load_furniture_facts()
	load_item_facts()
	load_door_facts()
	chain_facts()

func chain_facts() -> void:
	new_facts_added = true
	while new_facts_added:
		new_facts_added = false
		unvisited_door()
		check_item_for_locked_door()
		item_needed_at()
		craftable_items()
		need_craft()
		missing_requirements()

func load_inventory_facts() -> void:
	for item in inventory.contents:
		_create_fact(Fact.Type.HAS_ITEM, [item])

func load_container_facts() -> void:
	for container in memory.unopened_container_locations:
		_create_fact(Fact.Type.UNVISITED_CONTAINER_AT, [container])

func load_furniture_facts() -> void:
	for furniture in memory.furnitures:
		_create_fact(Fact.Type.FURNITURE_AT, [furniture])

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
func item_needed_at() -> void:
	for fact in facts[Fact.Type.NEED_ITEM]:
		for item_stored_fact in facts[Fact.Type.ITEM_STORED_AT]:
			if item_stored_fact.args[1] == fact.args[0]:
				if _create_fact(Fact.Type.ITEM_NEEDED_AT, 
					[item_stored_fact.args[0], fact.args[0]]):
					new_facts_added = true
				break
	
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
			DoorsData.LockTypes.BOARDED:
				item_needed = Inventory.ItemType.AXE
		if _has_fact(Fact.Type.HAS_ITEM, [item_needed]):
			if _create_fact(Fact.Type.UNLOCKABLE_DOOR_AT, [fact.args[0]]):
				new_facts_added = true
		else:
			if _create_fact(Fact.Type.NEED_ITEM, [item_needed]):
				new_facts_added = true



func craftable_items() -> void:
	_craftable_axe()

func _craftable_axe() -> void:
	_craftable(Inventory.ItemType.AXE, [
		Inventory.ItemType.AXE_HEAD,
		Inventory.ItemType.STICK,
		Inventory.ItemType.ROPE
	])

func _craftable(item: Inventory.ItemType, requirements: Array[Inventory.ItemType]) -> void:
	var requirements_achieved: Array[bool] = []
	
	for requirement in requirements:
		requirements_achieved.push_back(false)
	
	for fact in facts[Fact.Type.HAS_ITEM]:
		for i in range(requirements.size()):
			if fact.args[0] == requirements[i]:
				requirements_achieved[i] = true
	
	var missings: Array[Inventory.ItemType] = []
	for i in range(requirements_achieved.size()):
		if not requirements_achieved[i]:
			missings.push_back(requirements[i])
	
	if missings.is_empty():
		if _create_fact(Fact.Type.CRAFTABLE_ITEM, [item]):
			new_facts_added = true
	else:
		# Only get it if item is needed
		if not _has_fact(Fact.Type.NEED_ITEM, [item]):
			return
		for missing in missings:
			if _create_fact(Fact.Type.MISSING_CRAFTABLE_ITEM, [item, missing]):
				new_facts_added = true


func need_craft() -> void:
	_need_craft(Inventory.ItemType.AXE)

func _need_craft(item: Inventory.ItemType) -> void:
	var craftable: = _has_fact(Fact.Type.CRAFTABLE_ITEM, [item])
	var need: = _has_fact(Fact.Type.NEED_ITEM, [item])
	
	if craftable and need:
		if _create_fact(Fact.Type.NEED_CRAFT, [item]):
			new_facts_added = true

func missing_requirements() -> void:
	for fact in facts[Fact.Type.MISSING_CRAFTABLE_ITEM]:
		for item_loc in facts[Fact.Type.ITEM_STORED_AT]:
			var requirement_item: Inventory.ItemType = fact.args[1]
			var stored_item: Inventory.ItemType = item_loc.args[1]
			if requirement_item == stored_item:
				if _create_fact(Fact.Type.ITEM_NEEDED_AT, [item_loc.args[0], requirement_item]):
					new_facts_added = true

func _item_is_recipe_of(item: Inventory.ItemType, to_craft: Inventory.ItemType) -> bool:
	var recipe: Recipe = memory.get_recipe(to_craft)
	if recipe == null:
		return false
	
	return item in recipe.requirements

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
