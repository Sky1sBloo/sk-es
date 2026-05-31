extends Node
class_name WorldEditor

@export var cursor: Cursor
@export var world: Node2D

@export var tile_map_composition: TileMapComposition
@export var tile_map_details: TileMapDetails

@onready var world_selection: WorldSelection = $HUD/WorldSelection
@onready var limit_handler: LimitHandler = $LimitHandler
@onready var room_reader: RoomReader = $RoomReader
@onready var hud: EditorHud = $HUD

var world_packed: PackedScene = preload("res://Scenes/World/world.tscn")

var room_details: RoomDetails
const room_size: Vector2i =  Vector2i(17, 11)

signal edit_selected(pos: Vector2i, details: RoomDetails)
signal placed_cell(pos: Vector2i, select: WorldSelection.PlaceType)
signal deleted_cell(pos: Vector2i, cell_type: WorldSelection.PlaceType)

func _ready() -> void:
	_initialize_room()
	var rd: RoomDetails = GameConfiguration.room_details
	if rd == null:
		rd = room_reader.get_level("res://Levels/Sandbox.json")
	# replace the empty room_details with the loaded one
	room_details = rd

	# initialize cursor with the loaded room size so bounds match layout
	var rsize = Vector2i(room_details.room_layout[0].size(), room_details.room_layout.size())
	cursor.initialize(world.global_position, rsize)
	
	# render maps from room_details
	_load_composition_map()
	_load_details_map()
	
	# ensure limit handler counts match the loaded room
	# give the limit handler the authoritative RoomDetails and do an initial refresh
	limit_handler.set_room_details(room_details)
	hud.update_limits()
	hud.set_objective(room_details.objective)

func _refresh_limits() -> void:
	if room_details != null:
		limit_handler.update_counts_from_room()
		if hud != null:
			hud.update_limits()

func _initialize_room() -> void:
	room_details = RoomDetails.new()
	room_details.room_layout = []
	for y in room_size.y:
		room_details.room_layout.push_back([])
		for x in room_size.x:
			room_details.room_layout[y].push_back(0)

func _load_composition_map() -> void:
	if room_details == null:
		return
	tile_map_composition.clear()
	var init_player_pos = room_details.init_player_position
	if init_player_pos != null and init_player_pos != Vector2i(-1, -1):
		tile_map_composition.set_cell_type(room_details.init_player_position,
			TileMapComposition.CompositionType.START_POS)
	
	# walls
	for y in range(room_details.room_layout.size()):
		for x in range(room_details.room_layout[y].size()):
			if room_details.room_layout[y][x] == 1:
				tile_map_composition.set_cell_type(Vector2i(x, y), TileMapComposition.CompositionType.WALL)
	# exit
	if room_details.exit != null:
		tile_map_composition.set_cell_type(room_details.exit, TileMapComposition.CompositionType.EXIT)

	# doors
	if room_details.doors != null:
		for pos in room_details.doors:
			tile_map_composition.set_cell_type(room_details.doors[pos].grid_pos, TileMapComposition.CompositionType.DOOR)

	# traps (composition)
	if room_details.traps != null:
		for pos in room_details.traps:
			var trap: = room_details.traps[pos]
			tile_map_composition.set_cell_type(trap.grid_pos, TileMapComposition.CompositionType.SPIKE)

func _load_details_map() -> void:
	if room_details == null:
		return
	tile_map_details.clear()

	# locks / doors details
	if room_details.doors != null:
		for pos in room_details.doors:
			var door: = room_details.doors[pos]
			var detail_type: = TileMapDetails.lock_type_to_detail(door.lock_type)
			tile_map_details.set_cell_type(pos, detail_type)

	# containers
	if room_details.containers != null:
		for pos in room_details.containers:
			var container: = room_details.containers[pos]
			var type: = TileMapDetails.DetailType.CONTAINER
			if container.is_opened:
				type = TileMapDetails.DetailType.CONTAINER_OPENED
			tile_map_details.set_cell_type(pos, type)

	# furnitures
	if room_details.furnitures != null:
		for pos in room_details.furnitures:
			var furniture: = room_details.furnitures[pos]
			var dtype: = TileMapDetails.DetailType.UNKNOWN
			match furniture.type:
				FurnitureData.Types.TABLE:
					dtype = TileMapDetails.DetailType.TABLE
			tile_map_details.set_cell_type(pos, dtype)

	# traps details (show spike traps)
	if room_details.traps != null:
		for pos in room_details.traps:
			var trap: = room_details.traps[pos]
			# show trap detail regardless of any Jani memory
			tile_map_details.set_cell_type(trap.grid_pos, TileMapDetails.DetailType.SPIKE_TRAP)

func _on_start_button_pressed() -> void:
	if room_details.init_player_position == null or \
		room_details.exit == null:
			print("No start and end pos")
			return
	GameConfiguration.room_details = room_details
	get_tree().change_scene_to_packed(world_packed)

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
	# check limits before placing (use RoomDetails as source of truth)
	if not limit_handler.can_place(world_selection.place_type):
		#print("Placement denied by limit")
		return
	_handle_deletion(place_pos)
	placed_cell.emit(place_pos, world_selection.place_type)
	match world_selection.place_type:
		WorldSelection.PlaceType.WALLS:
			_place_wall(place_pos)
		WorldSelection.PlaceType.DOORS:
			_place_door(place_pos)
		WorldSelection.PlaceType.CONTAINERS:
			_place_containers(place_pos)
			# recompute counts and update HUD after placement
			_refresh_limits()
		WorldSelection.PlaceType.SPIKE:
			_place_spike(place_pos)
			_refresh_limits()
		WorldSelection.PlaceType.GLUE:
			_place_glue(place_pos)
			_refresh_limits()
		WorldSelection.PlaceType.TABLE:
			_place_table(place_pos)
			_refresh_limits()
		WorldSelection.PlaceType.EXIT:
			_place_exit(place_pos)
		WorldSelection.PlaceType.START_POS:
			_place_start_pos(place_pos)


func _on_limit_exceeded(pos: Vector2i, place_type) -> void:
	# simple feedback: print and (optionally) play a sound or flash UI
	print("Limit exceeded for placement: ", str(place_type), " at ", str(pos))


func _place_wall(place_pos: Vector2i) -> void:
	tile_map_composition.set_cell_type(place_pos, TileMapComposition.CompositionType.WALL)
	room_details.room_layout[place_pos.y][place_pos.x] = 1
	_refresh_limits()

func _place_door(place_pos: Vector2i) -> void:
	tile_map_composition.set_cell_type(place_pos, TileMapComposition.CompositionType.DOOR)
	var detail_type: = TileMapDetails.lock_type_to_detail(world_selection.lock_type)
	tile_map_details.set_cell_type(place_pos, detail_type)
	var door: = DoorsData.new()
	door.initialize(place_pos)
	door.lock_type = world_selection.lock_type
	door.is_locked = world_selection.lock_type != DoorsData.LockTypes.NONE
	room_details.doors[place_pos] = door
	_refresh_limits()

func _place_containers(place_pos: Vector2i) -> void:
	tile_map_details.set_cell_type(place_pos, TileMapDetails.DetailType.CONTAINER)
	var container_data: = ContainerData.new()
	container_data.grid_pos = place_pos
	container_data.contains = world_selection.selected_items.duplicate_deep()
	room_details.containers[place_pos] = container_data

func _place_spike(place_pos: Vector2i) -> void:
	tile_map_composition.set_cell_type(place_pos, TileMapComposition.CompositionType.SPIKE)
	var trap: = TrapData.new()
	trap.grid_pos = place_pos
	trap.type = TrapData.Types.SPIKED
	room_details.traps[place_pos] = trap

func _place_glue(place_pos: Vector2i) -> void:
	tile_map_composition.set_cell_type(place_pos, TileMapComposition.CompositionType.GLUE)
	var trap: = TrapData.new()
	trap.grid_pos = place_pos
	trap.type = TrapData.Types.GLUE
	room_details.traps[place_pos] = trap

func _place_table(place_pos: Vector2i) -> void:
	tile_map_details.set_cell_type(place_pos, TileMapDetails.DetailType.TABLE)
	var furniture: = FurnitureData.new()
	furniture.grid_pos = place_pos
	furniture.type = FurnitureData.Types.TABLE
	room_details.furnitures[place_pos] = furniture

func _place_exit(place_pos: Vector2i) -> void:
	if room_details.exit != null:
		tile_map_composition.set_cell_type(room_details.exit,
			TileMapComposition.CompositionType.NONE)
	
	tile_map_composition.set_cell_type(place_pos, 
		TileMapComposition.CompositionType.EXIT)
	room_details.exit = place_pos

func _place_start_pos(place_pos: Vector2i) -> void:
	if room_details.init_player_position != null:
		tile_map_composition.set_cell_type(room_details.init_player_position,
			TileMapComposition.CompositionType.NONE)
	tile_map_composition.set_cell_type(place_pos, 
		TileMapComposition.CompositionType.START_POS)
	room_details.init_player_position = place_pos
	

func _handle_deletion(pos: Vector2i) -> void:
	tile_map_composition.set_cell(pos, 0, Vector2i(14, 7))
	tile_map_details.set_cell_type(pos, TileMapDetails.DetailType.NONE)
	
	var wall: int = room_details.room_layout[pos.y][pos.x] 
	if wall == 1:
		room_details.room_layout[pos.y][pos.x] = 0
		deleted_cell.emit(pos, WorldSelection.PlaceType.WALLS)
		_refresh_limits()
	
	if room_details.doors.has(pos):
		room_details.doors.erase(pos)
		deleted_cell.emit(pos, WorldSelection.PlaceType.DOORS)
		_refresh_limits()
	
	if room_details.containers.has(pos):
		room_details.containers.erase(pos)
		deleted_cell.emit(pos, WorldSelection.PlaceType.CONTAINERS)
		_refresh_limits()
	
	if room_details.traps.has(pos):
		room_details.traps.erase(pos)
		deleted_cell.emit(pos, WorldSelection.PlaceType.SPIKE)
		_refresh_limits()
	
	if room_details.furnitures.has(pos):
		room_details.furnitures.erase(pos)
		deleted_cell.emit(pos, WorldSelection.PlaceType.TABLE)
		_refresh_limits()
	if room_details.init_player_position == pos:
		room_details.init_player_position = null
	if room_details.exit == pos:
		room_details.exit = null

func _on_world_selection_added_item(selected_item: Inventory.ItemType) -> void:
	if world_selection.mode_type != WorldSelection.ModeType.EDIT:
		return
	var edit_pos: = _get_cursor_grid_pos()
	if not room_details.containers.has(edit_pos):
		return
	room_details.containers[edit_pos].contains.push_back(selected_item)

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
	room_details.doors[edit_pos].is_locked = room_details.doors[edit_pos].lock_type != \
		DoorsData.LockTypes.NONE
	var detail_type: = TileMapDetails.lock_type_to_detail(world_selection.lock_type)
	tile_map_details.set_cell_type(edit_pos, detail_type)


func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu/main_menu.tscn")
