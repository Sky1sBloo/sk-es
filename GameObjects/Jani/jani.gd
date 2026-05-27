extends CharacterBody2D
class_name Jani

@onready var anim_tree : AnimationTree = $JaniAnimationTree
@onready var state_machine : JaniStateHandler = $StateHandler
@onready var memory : JaniMemory = $Memory
@onready var path_finder : PathFinder = $PathFinder
@onready var perceptor : Perceptor = $Perceptor
@onready var decision_manager : JaniDecisionManager = $DecisionManager
@onready var inventory: Inventory = $Inventory

@export var wasd_control: bool
@export var world: World

# Used to set origin position for offset
var _position_offset: Vector2 = Vector2.ZERO

# Triggers every grid movement
signal move_finished(pos: Vector2i)
# Triggers when end is reached
signal move_instruction_finished(pos: Vector2i)
signal interacted(action: Action, pos: Vector2i, args: Array)

var speed: int = 128 # 64
var direction: Vector2 = Vector2(0, 0)
var facing_direction: Vector2 = Vector2(0, 0)  # Used for animation
var target_directions: Array = []
var grid_position: Vector2

var state: JaniStateHandler.States:
	get:
		return state_machine.current_state
	set(value):
		state_machine.set_state(value)

# Position calculation
func initialize(offset_position: Vector2, initial_grid_pos: Vector2i) -> void:
	_position_offset = offset_position
	grid_position = initial_grid_pos
	global_position = Vector2(initial_grid_pos) * GameConfiguration.GRID_SIZE +  _position_offset
	memory.initialize(world.room.room_details)
	path_finder.initialize()
	decision_manager.clear_actions()
	decision_manager.tick()

# Doesn't forget memory
func reset(offset_position: Vector2, initial_grid_pos: Vector2i, ) -> void:
	_position_offset = offset_position
	target_directions.clear()
	inventory.clear()
	grid_position = initial_grid_pos
	global_position = Vector2(initial_grid_pos) * GameConfiguration.GRID_SIZE +  _position_offset
	direction = Vector2.ZERO
	state = JaniStateHandler.States.IDLE
	path_finder.initialize()
	decision_manager.clear_actions()
	decision_manager.tick()

func move_to_pos(target_position: Vector2i) -> void:
	clear_move_queue()
	var directions: = path_finder.find_path_as_directions(target_position, true)
	var pos: Vector2i = Vector2i(grid_position)
	for dir in directions:
		pos += dir
		# bounds check
		if memory.env_layout.size() == 0:
			# cannot validate without layout
			move_to(dir)
			continue
		if pos.y < 0 or pos.y >= memory.env_layout.size() or pos.x < 0 or pos.x >= memory.env_layout.front().size():
			move_to(dir)
			continue
		move_to(dir)

# Adds the movement direction to the queue
# Direction clamps to 1
func move_to(target_direction: Vector2i) -> void:
	target_direction.x = clamp(target_direction.x, -1, 1)
	target_direction.y = clamp(target_direction.y, -1, 1)
	target_directions.push_back(target_direction)

func clear_move_queue() -> void:
	target_directions.clear()

func interact(action: Action, pos: Vector2i = grid_position, args: Array = []) -> void:
	interacted.emit(action, pos, args)

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
	var target_position = Vector2i(grid_position) + target_directions.front()
	var target_position_grid = Vector2(target_position) * GameConfiguration.GRID_SIZE + _position_offset
	if global_position.distance_to(target_position_grid) <= 0.5:
		global_position = target_position_grid
		grid_position = target_position
		target_directions.pop_front()
		
		move_finished.emit(grid_position)
		if target_directions.size() == 0:
			move_instruction_finished.emit(grid_position)
	else:
		direction = global_position.direction_to(target_position_grid)
