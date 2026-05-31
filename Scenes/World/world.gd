extends Node
class_name World

@onready var jani: Jani = $Room/Jani
@onready var room_reader: RoomReader = $RoomReader
@onready var interaction_handler: InteractionHandler = $InteractionHandler
@onready var room: Room = $Room
@onready var goal_counter = $GoalCounter

var unedited_room: RoomDetails # For restart

var action_cost: int = 0 :
	get:
		return action_cost
	set(value):
		action_cost = value
		goal_counter.update_cost(value)

func _ready() -> void:
	start()

func reset() -> void:
	jani.clear_move_queue()
	start(true)

func start(keep_memory: bool = false) -> void:
	var room_details: RoomDetails = GameConfiguration.room_details
	unedited_room = room_details.clone()
	if room_details == null:
		room_details = room_reader.get_level("res://Levels/Sandbox.json")
	
	room.initialize(room_details)
	goal_counter.initialize(room_details)
	
	if room_details.goals != null:
		goal_counter.set_goals(room_details.goals)
	var _initial_pos: Vector2i = room_details.init_player_position if room_details.init_player_position != null else Vector2i(0, 0)
	if keep_memory:
		jani.memory.rebind(room_details)
		jani.reset($Room.global_position, _initial_pos)
	else:
		jani.initialize($Room.global_position, _initial_pos)
	interaction_handler.initialize(jani, room)


func _on_objectives_completed() -> void:
	#print("Objectives completed for this level")
	pass

func _on_interaction_handler_exit_reached() -> void:
	if goal_counter._objectives_completed:
		pass
	else:
		print("Failed")

func _on_restart_btn_pressed() -> void:
	GameConfiguration.room_details = unedited_room
	get_tree().change_scene_to_file("res://Scenes/WorldEditor/world_editor.tscn")

func _on_menu_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu/main_menu.tscn")
