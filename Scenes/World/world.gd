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
	var room_details: = room_reader.get_level("res://Levels/TestLevel2.json")
	room.initialize(room_details)
	if keep_memory:
		# Update memory to reference the new room details while keeping learned data
		jani.memory.rebind(room_details)
		jani.reset($Room.global_position, room_details.init_player_position)
	else:
		jani.initialize($Room.global_position, room_details.init_player_position)
	interaction_handler.initialize(jani, room)
	
