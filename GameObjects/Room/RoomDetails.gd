extends RefCounted
class_name RoomDetails

enum TileType {
	EMPTY = 0,
	WALL = 1,
	DOOR = 2,
	SPIKE = 3,
	EXIT = 4,
	JANI = 99
}

# 2D array of int
var room_layout: Array
var init_player_position: Vector2i
var exit: Vector2i
var doors: Dictionary[Vector2i, DoorsData]
var containers: Dictionary[Vector2i, ContainerData]
var furnitures: Dictionary[Vector2i, FurnitureData]
var traps: Array[TrapData]

func get_cell_trap(pos: Vector2i) -> TrapData:
	for trap in traps:
		if trap.grid_pos == pos:
			return  trap
	return null

func get_cell_door(pos: Vector2i) -> DoorsData:
	if doors.has(pos):
		return doors[pos]
	return null

func get_cell_container(pos: Vector2i) -> ContainerData:
	if containers.has(pos):
		return containers[pos]
	return null

func get_cell_furniture(pos: Vector2i) -> FurnitureData:
	if furnitures.has(pos):
		return furnitures[pos]
	return null
