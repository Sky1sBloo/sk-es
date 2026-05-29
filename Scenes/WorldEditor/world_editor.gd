extends Node

@export var cursor: Cursor
@export var world: Node2D

@export var tile_map_composition: TileMapLayer

@onready var world_selection: WorldSelection = $HUD/WorldSelection

var room_details: RoomDetails
const room_size: Vector2i =  Vector2i(16, 10)

enum CompositionType {
	WALL,
	DOOR,
	SPIKE,
	EXIT
}

var _composition_atlas: Dictionary[CompositionType, Vector2i] = {
	CompositionType.WALL: Vector2i(0, 0),
	CompositionType.DOOR: Vector2i(1, 0),
	CompositionType.SPIKE: Vector2i(3, 0),
	CompositionType: Vector2i(0, 3)
}

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
	_handle_placing()

func _handle_placing() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var place_pos: = _position_to_grid_pos(cursor.global_position)
		if not cursor.able_to_place:
			return
		_place(place_pos)

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if not cursor.able_to_place:
			return
		var place_pos: = _position_to_grid_pos(cursor.global_position)
		tile_map_composition.set_cell(place_pos, 0, Vector2i(14, 7))
		room_details.room_layout[place_pos.y][place_pos.x] = 0

func _place(place_pos: Vector2i) -> void:
	match world_selection.place_type:
		WorldSelection.PlaceType.WALLS:
			_place_wall(place_pos)
		WorldSelection.PlaceType.DOORS:
			_place_door(place_pos)
		WorldSelection.PlaceType.CONTAINERS:
			pass

func _place_wall(place_pos: Vector2i) -> void:
	tile_map_composition.set_cell(place_pos, 0, _composition_atlas[CompositionType.WALL])
	room_details.room_layout[place_pos.y][place_pos.x] = 1

func _place_door(place_pos: Vector2i) -> void:
	tile_map_composition.set_cell(place_pos, 0, _composition_atlas[CompositionType.DOOR])
	var door: = DoorsData.new()
	door.initialize(place_pos)
	room_details.doors[place_pos] = door

func _place_containers(place_pos: Vector2i) -> void:
	pass

func _position_to_grid_pos(pos: Vector2) -> Vector2i:
	var offset: = world.global_position
	var grid_size: = GameConfiguration.GRID_SIZE
	
	var local_pos: = pos - offset
	return Vector2i(
		floor(local_pos.x / grid_size),
		floor(local_pos.y / grid_size)
	)
