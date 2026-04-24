extends Node2D
class_name Room

@export var composition_map: TileMapLayer
@export var details_map: TileMapLayer

enum LayoutDetails {
	EMPTY,
	WALL,
	DOOR,
	BOARDED_DOOR,
	LOCKED_RED,
	LOCKED_YELLOW,
	LOCKED_GREEN,
	ITEM_KEYRED,
	ITEM_KEYYELLOW,
	ITEM_KEYGREEN,
	ITEM_NOTHING
}

var room_layout: Array

var composition_atlas: Dictionary[LayoutDetails, Vector2i] = {
	LayoutDetails.EMPTY: Vector2i(3, 0),
	LayoutDetails.WALL: Vector2i(0, 0),
	LayoutDetails.DOOR: Vector2i(1, 0),
	LayoutDetails.BOARDED_DOOR: Vector2i(2, 0),
	LayoutDetails.LOCKED_RED: Vector2i(1, 0),
	LayoutDetails.LOCKED_YELLOW: Vector2i(1, 0),
	LayoutDetails.LOCKED_GREEN: Vector2i(1, 0),
	LayoutDetails.ITEM_KEYRED: Vector2i(1, 2),
	LayoutDetails.ITEM_KEYYELLOW: Vector2i(2, 2),
	LayoutDetails.ITEM_KEYGREEN: Vector2i(3, 2)
}

var details_atlas: Dictionary[LayoutDetails, Vector2i] = {
	LayoutDetails.LOCKED_RED: Vector2i(1, 1),
	LayoutDetails.LOCKED_YELLOW: Vector2i(2, 1),
	LayoutDetails.LOCKED_GREEN: Vector2i(3, 1),
	LayoutDetails.ITEM_KEYRED: Vector2i(0, 1),
	LayoutDetails.ITEM_KEYYELLOW: Vector2i(0, 1),
	LayoutDetails.ITEM_KEYGREEN: Vector2i(0, 1)
}

func initialize(room_details: RoomDetails) -> void:
	composition_map.clear()
	room_layout = room_details.room_layout
	setup_composition()
	setup_details()

func setup_composition() -> void:
	for y in range(room_layout.size()):
		for x in range(room_layout[y].size()):
			composition_map.set_cell(Vector2i(x, y), 0, composition_atlas[room_layout[y][x]])

func setup_details() -> void:
	for y in range(room_layout.size()):
		for x in range(room_layout[y].size()):
			if details_atlas.has(room_layout[y][x]):
				details_map.set_cell(Vector2i(x, y), 0, details_atlas[room_layout[y][x]])

func _create_wall_positions() -> Array[Vector2i]:
	var wall_positions: Array[Vector2i]
	for y in range(room_layout.size()):
		for x in range(room_layout[y].size()):
			if room_layout[y][x] == LayoutDetails.WALL:
				wall_positions.push_back(Vector2i(x, y))
	return wall_positions
