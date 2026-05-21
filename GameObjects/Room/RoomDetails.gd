extends RefCounted
class_name RoomDetails

enum TileType {
	EMPTY = 0,
	WALL = 1,
	DOOR = 2,
	SPIKE = 3,
	JANI = 99
}

# 2D array of int
var room_layout: Array
var init_player_position: Vector2i
var doors: Array[DoorsData]
var containers: Array[ContainerData]
var traps: Array[TrapData]

func is_cell_trap(pos: Vector2i) -> bool:
	for trap in traps:
		if trap.grid_pos == pos:
			return true
	return false
