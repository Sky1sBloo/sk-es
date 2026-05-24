extends Node
class_name JaniDecisionManager

@export var perceptor: Perceptor
@onready var jani: Jani = get_parent()
@onready var inference: Inference = $Inference

var action_queue: = ActionQueue.new()

func tick() -> void:
	perceptor.percept_room()
	inference.load_facts()
	fact_to_action()
	print("======")
	for type in inference.facts:
		for fact in inference.facts[type]:
			print("Fact: ", Fact.type_to_string(fact.type), fact.args)
	decide()

func fact_to_action() ->  void:
	for fact in inference.facts[Fact.Type.UNVISITED_DOOR_AT]:
		var action = Action.new()
		action.type = Action.Types.VISIT_DOOR
		action.grid_pos = fact.args[0]
		action.interaction_pos = fact.args[0]
		action_queue.push(action)
	
	for fact in inference.facts[Fact.Type.NEED_ITEM]:
		# loop through unvisited containers and interact, only until it gets the item will we remove that fact
		if inference.facts[Fact.Type.UNVISITED_CONTAINER_AT].is_empty():
			print("Cannot escape")
			continue
		else:
			var action = Action.new()
			var container_fact = inference.facts[Fact.Type.UNVISITED_CONTAINER_AT][0]
			action.type = Action.Types.OPEN_CONTAINER
			action.grid_pos = container_fact.args[0]
			action.interaction_pos = container_fact.args[0]
			action_queue.push(action)
	
	for fact in inference.facts[Fact.Type.UNLOCKABLE_DOOR_AT]:
		var action = Action.new()
		action.type = Action.Types.OPEN_DOOR
		action.grid_pos = fact.args[0]
		action.interaction_pos = fact.args[0]
		action_queue.push(action)
	
	for fact in inference.facts[Fact.Type.FOUND_EXIT]:
		var action = Action.new()
		action.type = Action.Types.GO_TO_EXIT
		action.grid_pos = fact.args[0]
		action_queue.push(action)

func decide() -> void:
	var next_action: Action = action_queue.peek()
	if action_queue.is_empty():
		print("nothing to do")
		return
	print("Action size: ", action_queue.size())
	print(Action.type_to_string(next_action.type))
	match next_action.type:
		Action.Types.VISIT_DOOR:
			jani.move_to_pos(next_action.grid_pos)
		Action.Types.OPEN_CONTAINER:
			jani.move_to_pos(next_action.grid_pos)
		Action.Types.OPEN_DOOR:
			jani.move_to_pos(next_action.grid_pos)
		Action.Types.GO_TO_EXIT:
			jani.move_to_pos(next_action.grid_pos)
		_:
			print("Unknown action type")

func _on_jani_move_instruction_finished(_pos: Vector2i) -> void:
	# To do filter by action
	if action_queue.is_empty():
		return
	var action = action_queue.peek()
	# Defensive: ensure action is valid
	if action == null:
		tick()
		return
	action_queue.pop()
	if action.interaction_pos != Vector2i(-1, -1):
		jani.interact(action.interaction_pos)
	tick()

func cancel_current_action() -> void:
	# Remove the current/top action from the queue if present.
	if not action_queue.is_empty():
		action_queue.pop()

func clear_actions() -> void:
	# Remove all pending actions while preserving the ActionQueue instance
	if action_queue != null:
		# best-effort: try to clear internal heap array if present
		if typeof(action_queue._heap) == TYPE_ARRAY:
			action_queue._heap.clear()
			return
	# Fallback: replace the queue
	action_queue = ActionQueue.new()
