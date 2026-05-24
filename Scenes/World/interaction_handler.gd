extends Node
class_name InteractionHandler

var jani: Jani
var room: Room
@onready var world: World = get_parent()

func initialize(jani_node: Jani, room_node: Room) -> void:
	jani = jani_node
	room = room_node

func _on_jani_move_finished(pos: Vector2i) -> void:
	if room.room_details.get_cell_trap(pos) != null:
		jani.memory.add_trap(pos)
		# Cancel the current action so the decision manager doesn't get out of sync
		if jani.has_node("DecisionManager"):
			jani.decision_manager.cancel_current_action()
		world.reset()
		room.details_map.set_cell(pos, 0, room.details_atlas[room.DetailType.NONE])

func _on_jani_interacted(action: Action, pos: Vector2i, args: Array) -> void:
	_container_interaction(action)
	_furniture_interaction(pos, args)
	_door_interaction(pos)

func _old_container_interaction(pos: Vector2i) -> void:
	var container: = room.room_details.get_cell_container(pos) 
	if container != null and not container.is_opened:
		container.is_opened = true
		jani.memory.unopened_container_locations.erase(container.grid_pos)
		for item in container.contains:
			jani.inventory.push_item(item)

# args: Array[Items]
func _container_interaction(action: Action) -> void:
	var pos: = action.grid_pos
	var container: = room.room_details.get_cell_container(pos) 
	if container == null:
		return
	
	if container.is_opened:
		var to_delete_item: Array[Inventory.ItemType] = []
		if action.type == Action.Types.GET_ITEM_FROM_CONTAINER:
			for item in action.args:
				if not container.contains.has(item):
					print("container doesn't have item")
					continue
				jani.inventory.push_item(item)
				to_delete_item.push_back(item)
			for item in to_delete_item:
				container.contains.erase(item)
	else:
		container.open()
		jani.memory.unopened_container_locations.erase(container.grid_pos)
		for item in container.contains:
			jani.memory.item_locations.push_back([pos, item])

func _furniture_interaction(pos: Vector2i, args: Array) -> void:
	var furniture: = room.room_details.get_cell_furniture(pos)
	if furniture == null:
		return
	
	# Crafting able
	if furniture.type == FurnitureData.Types.TABLE:
		if args.is_empty():
			print("cannot craft args is empty")
			return
		
		jani.inventory.craft_item(args[0])

func _door_interaction(pos: Vector2i) -> void:
	var door: = room.room_details.get_cell_door(pos)
	if door == null or not door.is_locked:
		return
	# First interaction: record lock type in memory
	if not jani.memory.door_lock_type.has(door.grid_pos):
		jani.memory.door_lock_type[door.grid_pos] = door.lock_type
		return
	# Second interaction: only unlock if Jani has the corresponding key
	var needed_item: Inventory.ItemType
	match door.lock_type:
		DoorsData.LockTypes.RED:
			needed_item = Inventory.ItemType.RED_KEY
		DoorsData.LockTypes.GREEN:
			needed_item = Inventory.ItemType.GREEN_KEY
		DoorsData.LockTypes.YELLOW:
			needed_item = Inventory.ItemType.YELLOW_KEY
		DoorsData.LockTypes.BOARDED:
			needed_item = Inventory.ItemType.AXE
		_:
			# Unknown lock type; do not unlock
			return
	if jani.inventory.contents.has(needed_item):
		jani.memory.locked_door_locations.erase(pos)
		jani.memory.door_lock_type.erase(pos)
		door.unlock()
