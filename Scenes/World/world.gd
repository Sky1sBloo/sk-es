extends Node
class_name World

@onready var jani: Jani = $Room/Jani
@onready var room_reader: RoomReader = $RoomReader
@onready var interaction_handler: InteractionHandler = $InteractionHandler
@onready var room: Room = $Room

func _ready() -> void:
	start()

func reset() -> void:
	jani.clear_move_queue()
	start(true)

func start(keep_memory: bool = false) -> void:
	var room_details: = room_reader.get_level("res://Levels/TestLevel.json")
	room.initialize(room_details)
	if keep_memory:
		jani.reset($Room.global_position, room_details.init_player_position)
	else:
		jani.initialize($Room.global_position, room_details.init_player_position, room_details)
	interaction_handler.initialize(jani, room)
	jani.memory.env_layout = room_details.room_layout
	await test_unlock_door(room_details)
	jani.move_to_pos(Vector2i(6, 8))

func test_unlock_door(room_details: RoomDetails) -> void:
	await get_tree().create_timer(2).timeout
	room_details.doors[0].unlock_door()
