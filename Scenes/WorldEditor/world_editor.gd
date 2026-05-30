extends Node
class_name WorldEditor

@export var cursor: Cursor
@export var world: Node2D

@export var tile_map_composition: TileMapComposition
@export var tile_map_details: TileMapDetails

@onready var world_selection: WorldSelection = $HUD/WorldSelection

var room_details: RoomDetails
const room_size: Vector2i =  Vector2i(17, 11)

signal edit_selected(pos: Vector2i, details: RoomDetails)

func _ready() -> void:
	_initialize_room()
	cursor.initialize(world.global_position)

func _initialize_room() -> void:
	room_details = RoomDetails.new()
	room_details.room_layout = []
	for y in room_size.y:
		room_details.room_layout.push_back([])
		for x in room_size.x:
			room_details.room_layout[y].push_back(0)

func _process(_delta: float) -> void:
	if world_selection.is_selecting():
		return
	
	match world_selection.mode_type:
		WorldSelection.ModeType.PLACE:
			_handle_placing()
			cursor.move_to_mouse()

func _handle_placing() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if world_selection.place_type != WorldSelection.PlaceType.WALLS:
			return
		var place_pos: = _position_to_grid_pos(cursor.global_position)
		if not cursor.able_to_place:
			return
		_place(place_pos)

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if not cursor.able_to_place:
			return
		var place_pos: = _get_cursor_grid_pos()
		_handle_deletion(place_pos)

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	if not event.pressed:
		return
	if event.button_index != MOUSE_BUTTON_LEFT:
		return
	match world_selection.mode_type:
		WorldSelection.ModeType.PLACE:
			_handle_single_placing()
		WorldSelection.ModeType.EDIT:
			cursor.move_to_mouse_edit()
			edit_selected.emit(_position_to_grid_pos(cursor.global_position),
				room_details)

func _handle_single_placing() -> void:
	if world_selection.mode_type != WorldSelection.ModeType.PLACE:
		return
	var place_pos: = _get_cursor_grid_pos()
	if not cursor.able_to_place:
		return
	_place(place_pos)

func _place(place_pos: Vector2i) -> void:
	if not cursor.able_to_place:
		return
	_handle_deletion(place_pos)
	match world_selection.place_type:
		WorldSelection.PlaceType.WALLS:
			_place_wall(place_pos)
		WorldSelection.PlaceType.DOORS:
			_place_door(place_pos)
		WorldSelection.PlaceType.CONTAINERS:
			_place_containers(place_pos)
		WorldSelection.PlaceType.TRAP:
			_place_traps(place_pos)

func _place_wall(place_pos: Vector2i) -> void:
	tile_map_composition.set_cell_type(place_pos, TileMapComposition.CompositionType.WALL)
	room_details.room_layout[place_pos.y][place_pos.x] = 1

func _place_door(place_pos: Vector2i) -> void:
	tile_map_composition.set_cell_type(place_pos, TileMapComposition.CompositionType.DOOR)
	var detail_type: = TileMapDetails.lock_type_to_detail(world_selection.lock_type)
	tile_map_details.set_cell_type(place_pos, detail_type)
	var door: = DoorsData.new()
	door.initialize(place_pos)
	door.lock_type = world_selection.lock_type
	room_details.doors[place_pos] = door

func _place_containers(place_pos: Vector2i) -> void:
	tile_map_details.set_cell_type(place_pos, TileMapDetails.DetailType.CONTAINER)
	var container_data: = ContainerData.new()
	container_data.grid_pos = place_pos
	container_data.contains = world_selection.selected_items.duplicate_deep()
	room_details.containers[place_pos] = container_data

func _place_traps(place_pos: Vector2i) -> void:
	tile_map_composition.set_cell_type(place_pos, TileMapComposition.CompositionType.SPIKE)
	var trap: = TrapData.new()
	trap.grid_pos = place_pos
	trap.type = TrapData.Types.SPIKED
	room_details.traps[place_pos] = trap

func _handle_deletion(pos: Vector2i) -> void:
	tile_map_composition.set_cell(pos, 0, Vector2i(14, 7))
	tile_map_details.set_cell_type(pos, TileMapDetails.DetailType.NONE)
	room_details.room_layout[pos.y][pos.x] = 0
	room_details.doors.erase(pos)
	room_details.containers.erase(pos)
	room_details.traps.erase(pos)

func _on_world_selection_added_item(selected_item: Inventory.ItemType) -> void:
	if world_selection.mode_type != WorldSelection.ModeType.EDIT:
		return
	var edit_pos: = _get_cursor_grid_pos()
	if not room_details.containers.has(edit_pos):
		return
	room_details.containers[edit_pos].contains.push_back(selected_item)
	print(selected_item)

func _on_world_selection_removed_item() -> void:
	if world_selection.mode_type != WorldSelection.ModeType.EDIT:
		return
	var edit_pos: = _get_cursor_grid_pos()
	if not room_details.containers.has(edit_pos):
		return
	room_details.containers[edit_pos].contains.pop_back()

func _get_cursor_grid_pos() -> Vector2i:
	return _position_to_grid_pos(cursor.global_position)

func _position_to_grid_pos(pos: Vector2) -> Vector2i:
	var offset: = world.global_position
	var grid_size: = GameConfiguration.GRID_SIZE
	
	var local_pos: = pos - offset
	return Vector2i(
		floor(local_pos.x / grid_size),
		floor(local_pos.y / grid_size)
	)

func _on_lock_selection_item_selected(index: int) -> void:
	if world_selection.mode_type != WorldSelection.ModeType.EDIT:
		return
	var edit_pos: = _get_cursor_grid_pos()
	if not room_details.doors.has(edit_pos):
		return
	room_details.doors[edit_pos].lock_type = index as DoorsData.LockTypes
	var detail_type: = TileMapDetails.lock_type_to_detail(world_selection.lock_type)
	tile_map_details.set_cell_type(edit_pos, detail_type)
