extends Node
class_name World

@onready var jani: Jani = $Room/Jani
@onready var room_reader: RoomReader = $RoomReader
@onready var room: Room = $Room
@onready var path_finder: PathFinder = $PathFinder

func _ready() -> void:
	var room_details: = room_reader.get_level("res://Levels/TestLevel.json")
	room.initialize(room_details)
	jani.initialize($Room.global_position, room_details.init_player_position)
	await test_unlock_door(room_details)
	var dirs: = path_finder.find_path_as_directions(room_details.init_player_position, 
		Vector2i(6, 8), room_details)
	for dir in dirs:
		jani.move_to(dir)

func test_unlock_door(room_details: RoomDetails) -> void:
	await get_tree().create_timer(2).timeout
	room_details.doors[0].unlock_door()
