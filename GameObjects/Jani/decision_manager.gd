extends Node
class_name JaniDecisionManager

@export var perceptor: Perceptor
@export var path_finder: PathFinder
@onready var jani: Jani = get_parent()
@onready var inference: Inference = $Inference

var action_queue: = ActionQueue.new()

func tick() -> void:
	perceptor.percept_room()
	inference.load_facts()
	fact_to_action()
	decide()

func fact_to_action() ->  void:
	for fact in inference.facts[Fact.Type.UNVISITED_DOOR_AT]:
		_create_action(Action.Types.VISIT_DOOR, fact.args[0], fact.args[0])
		
	# retrieve already-known needed items
	for fact in inference.facts[Fact.Type.ITEM_NEEDED_AT]:
		# ITEM_NEEDED_AT = [pos, item]
		_create_action(Action.Types.GET_ITEM_FROM_CONTAINER, fact.args[0], 
			fact.args[0], [fact.args[1]])
	
	# If we still need items but don't know where they are,
	# continue exploring unopened containers
	if not inference.facts[Fact.Type.NEED_ITEM].is_empty():
		var unresolved_need := false
		for need_fact in inference.facts[Fact.Type.NEED_ITEM]:
			var needed_item: Inventory.ItemType = need_fact.args[0]
			var found_location := false
			for item_fact in inference.facts[Fact.Type.ITEM_NEEDED_AT]:
				if item_fact.args[1] == needed_item:
					found_location = true
					break
			if not found_location:
				unresolved_need = true
				break
		if unresolved_need:
			if inference.facts[Fact.Type.UNVISITED_CONTAINER_AT].is_empty():
				print("No container left")
			else:
				var container_fact = inference.facts[Fact.Type.UNVISITED_CONTAINER_AT][0]
				_create_action(Action.Types.OPEN_CONTAINER, container_fact.args[0],
					container_fact.args[0])
	
	for fact in inference.facts[Fact.Type.UNLOCKABLE_DOOR_AT]:
		_create_action(Action.Types.OPEN_DOOR, fact.args[0], fact.args[0])
	
	for fact in inference.facts[Fact.Type.NEED_CRAFT]:
		# Todo support nearest furniture
		for furniture in inference.facts[Fact.Type.FURNITURE_AT]:
			var furniture_data: FurnitureData = furniture.args[0]
			if furniture.args[0].type != FurnitureData.Types.TABLE:
				continue
			_create_action(Action.Types.CRAFT_ITEM, furniture_data.grid_pos,
				furniture_data.grid_pos, [fact.args[0]])
	
	for fact in inference.facts[Fact.Type.FOUND_EXIT]:
		_create_action(Action.Types.GO_TO_EXIT, fact.args[0], fact.args[0])

func _create_action(type: Action.Types, walk_pos: Vector2i, 
		interaction_pos: Vector2i = Vector2i(-1, -1),
		args: Array = []):
	if not _is_reachable(walk_pos):
		return
	var action = Action.new()
	action.type = type
	action.grid_pos = walk_pos
	action.interaction_pos = interaction_pos
	action.args = args
	action_queue.push(action)

func decide() -> void:
	var next_action: Action = action_queue.peek()
	if action_queue.is_empty():
		print("nothing to do")
		return
	match next_action.type:
		Action.Types.VISIT_DOOR:
			jani.move_to_pos(next_action.grid_pos)
		Action.Types.OPEN_CONTAINER:
			jani.move_to_pos(next_action.grid_pos)
		Action.Types.OPEN_DOOR:
			jani.move_to_pos(next_action.grid_pos)
		Action.Types.GO_TO_EXIT:
			jani.move_to_pos(next_action.grid_pos)
		Action.Types.CRAFT_ITEM:
			jani.move_to_pos(next_action.grid_pos)
		Action.Types.GET_ITEM_FROM_CONTAINER:
			jani.move_to_pos(next_action.grid_pos)
		_:
			print("Unknown action type")

func _is_reachable(pos: Vector2i) -> bool:
	var path: = path_finder.find_path_as_directions(jani.grid_position, pos, jani.memory)
	
	return not path.is_empty()

func log_facts() -> void:
	print("======")
	for type in inference.facts:
		for fact in inference.facts[type]:
			print("Fact: ", fact.to_string())

func _on_jani_move_instruction_finished(_pos: Vector2i) -> void:
	# To do filter by action
	if action_queue.is_empty():
		return
	var action = action_queue.peek()
	action_queue.pop()
	if action == null:
		tick()
		return
	
	if action.interaction_pos != Vector2i(-1, -1):
		jani.interact(action, action.interaction_pos, action.args)
	if action.type == Action.Types.GO_TO_EXIT:
		return
	tick()

func cancel_current_action() -> void:
	# Remove the current/top action from the queue if present.
	if not action_queue.is_empty():
		action_queue.pop()

func clear_actions() -> void:
	action_queue = ActionQueue.new()
