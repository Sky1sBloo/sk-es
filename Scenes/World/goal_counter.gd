extends Node

var interaction_count: int = 0
var move_count: int = 0
var container_checked: int = 0
var door_opened: int = 0
var trap_triggered: int = 0
var cost_reached: int = 0

signal objectives_completed

var goals: Dictionary = {}
var _objectives_completed: bool = false

func initialize(room_details: RoomDetails) -> void:
	for pos in room_details.traps:
		room_details.traps[pos].triggered.connect(_on_trap_triggered)
		print(pos)

func _on_jani_move_finished(_pos: Vector2i) -> void:
	move_count += 1
	_check_and_emit()

func _on_jani_interacted(_action: Action, _pos: Vector2i, _args: Array) -> void:
	interaction_count += 1
	
	if _action.type == Action.Types.OPEN_CONTAINER:
		container_checked += 1
	
	if _action.type == Action.Types.OPEN_DOOR:
		door_opened += 1

	_check_and_emit()

func _on_trap_triggered(_grid_pos: Vector2i, _type: TrapData.Types) -> void:
	trap_triggered += 1
	_check_and_emit()


func set_goals(g: Dictionary) -> void:
	goals = g.duplicate(true)
	_objectives_completed = false
	_check_and_emit()


func _check_and_emit() -> void:
	if _objectives_completed:
		return
	if _objectives_met():
		_objectives_completed = true
		objectives_completed.emit()


func _objectives_met() -> bool:
	# If no goals defined, do not treat objectives as met.
	if goals == null or goals.keys().size() == 0:
		return false

	# Iterate goals dictionary and compare against tracked counters.
	for key in goals.keys():
		var required = int(goals[key])
		var current = 0
		match key:
			"interaction_count":
				current = interaction_count
			"move_count":
				current = move_count
			"container_checked":
				current = container_checked
			"door_opened":
				current = door_opened
			"trap_triggered":
				current = trap_triggered
			_:
				continue
		if current < required:
			return false
	return true
