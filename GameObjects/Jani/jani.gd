extends CharacterBody2D
class_name Jani

@onready var anim_tree : AnimationTree = $JaniAnimationTree
@onready var state_machine : JaniStateHandler = $StateHandler
@onready var memory : JaniMemory = $Memory
@onready var path_finder : PathFinder = $PathFinder

@export var wasd_control: bool

# Used to set origin position for offset
var _position_offset: Vector2 = Vector2.ZERO

signal move_finished(pos: Vector2i)

var speed: int = 64
var direction: Vector2 = Vector2(0, 0)
var facing_direction: Vector2 = Vector2(0, 0)  # Used for animation
var target_directions: Array[Vector2]
var grid_position: Vector2

var state: JaniStateHandler.States:
	get:
		return state_machine.current_state
	set(value):
		state_machine.set_state(value)

# Position calculation
func initialize(offset_position: Vector2, initial_grid_pos: Vector2i, 
		room_details: RoomDetails) -> void:
	memory.initialize(room_details)
	path_finder.initialize()
	_position_offset = offset_position
	grid_position = initial_grid_pos
	global_position = Vector2(initial_grid_pos) * GameConfiguration.GRID_SIZE +  _position_offset

# Doesn't forget memory
func reset(offset_position: Vector2, initial_grid_pos: Vector2i, ) -> void:
	_position_offset = offset_position
	path_finder.initialize()
	grid_position = initial_grid_pos
	global_position = Vector2(initial_grid_pos) * GameConfiguration.GRID_SIZE +  _position_offset

func move_to_pos(target_position: Vector2i) -> void:
	var path: = path_finder.find_path_as_directions(grid_position, target_position, memory)
	for line in path:
		move_to(line)

# Adds the movement direction to the queue
# Direction clamps to 1
func move_to(target_direction: Vector2i) -> void:
	target_direction.x = clamp(target_direction.x, -1, 1)
	target_direction.y = clamp(target_direction.y, -1, 1)
	target_directions.push_back(target_direction)

func clear_move_queue() -> void:
	target_directions.clear()

func _control_manually() -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	direction = input_dir

func _update_animation() -> void:
	anim_tree.set("parameters/conditions/is_moving", state == JaniStateHandler.States.WALKING)
	anim_tree.set("parameters/conditions/not_moving", state == JaniStateHandler.States.IDLE)
	
	if state == JaniStateHandler.States.WALKING:
		facing_direction = direction
		anim_tree.set("parameters/Moving/blend_position", facing_direction)
		anim_tree.set("parameters/Idle/blend_position", facing_direction)

func _physics_process(_delta: float) -> void:
	if (wasd_control):
		_control_manually()
	else:
		_move_to_position()
	_update_animation()
	
	velocity = direction * speed
	move_and_slide()

func _move_to_position() -> void:
	if (target_directions.size() == 0):
		direction = Vector2.ZERO
		return
	var target_position = grid_position + target_directions.front()
	var target_position_grid = target_position * GameConfiguration.GRID_SIZE + _position_offset
	if global_position.distance_to(target_position_grid) <= 0.5:
		global_position = target_position_grid
		grid_position = target_position
		target_directions.pop_front()
		
		move_finished.emit(grid_position)
	else:
		direction = global_position.direction_to(target_position_grid)
