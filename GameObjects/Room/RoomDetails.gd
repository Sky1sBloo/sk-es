extends RefCounted
class_name RoomDetails

enum TileType {
	EMPTY = 0,
	WALL = 1,
	DOOR = 2,
	JANI = 99
}

# 2D array of int
var room_layout: Array
var init_player_position: Vector2i
var doors: Array[DoorsData]
