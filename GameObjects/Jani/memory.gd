extends Node
class_name JaniMemory

# Checks the environment layout
var env_layout: Array = []
var doors: Array[DoorsData] = []

func initialize(room_details: RoomDetails) -> void:
	env_layout = room_details.room_layout
	doors = room_details.doors

func add_trap(pos: Vector2i) -> void:
	env_layout[pos.y][pos.x] = 1
