extends Node
class_name World

@onready var jani: Jani = $Room/Jani
@onready var room_reader: RoomReader = $RoomReader
@onready var interaction_handler: InteractionHandler = $InteractionHandler
@onready var room: Room = $Room
@onready var cursor: Cursor = $Cursor
@onready var goal_counter = $GoalCounter

var action_cost: int = 0

func _ready() -> void:
	start()
	# initialize cursor with room size so bounds are correct
	var room_size = Vector2i(room.room_details.room_layout[0].size(), room.room_details.room_layout.size())
	cursor.initialize(room.global_position, room_size)

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	if not event.pressed:
		return
	if event.button_index != MOUSE_BUTTON_LEFT:
		return
	cursor.move_to_mouse_edit()
func reset() -> void:
	jani.clear_move_queue()
	start(true)

func start(keep_memory: bool = false) -> void:
	var room_details: = GameConfiguration.room_details
	if room_details == null:
		room_details = room_reader.get_level("res://Levels/TestLevel.json")
	
	room.initialize(room_details)
	goal_counter.initialize(room_details)
	
	if room_details.goals != null:
		goal_counter.set_goals(room_details.goals)
	if keep_memory:
		jani.memory.rebind(room_details)
		jani.reset($Room.global_position, room_details.init_player_position)
	else:
		jani.initialize($Room.global_position, room_details.init_player_position)
	interaction_handler.initialize(jani, room)


func _on_objectives_completed() -> void:
	print("Objectives completed for this level")
	# TODO: trigger end-of-level flow, show HUD message, etc.
