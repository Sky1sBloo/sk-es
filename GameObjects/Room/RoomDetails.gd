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
var doors: Array[DoorsData]
var containers: Array[ContainerData]
var furnitures: Array[FurnitureData]
var traps: Array[TrapData]

func get_cell_trap(pos: Vector2i) -> TrapData:
	for trap in traps:
		if trap.grid_pos == pos:
			return  trap
	return null

func get_cell_door(pos: Vector2i) -> DoorsData:
	for door in doors:
		if door.grid_pos == pos:
			return door
	return null

func get_cell_container(pos: Vector2i) -> ContainerData:
	for container in containers:
		if container.grid_pos == pos:
			return container
	return null

func get_cell_furniture(pos: Vector2i) -> FurnitureData:
	for furniture in furnitures:
		if furniture.grid_pos == pos:
			return furniture
	return null
