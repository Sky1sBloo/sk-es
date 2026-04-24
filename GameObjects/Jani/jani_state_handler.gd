extends Node
class_name JaniStateHandler

@export var jani : Jani

enum States {
	IDLE,
	WALKING
}
var current_state: States = States.IDLE
var prev_state: States = States.IDLE

func set_state(state: States):
	prev_state = current_state
	current_state = state

func _state_idle_process(_delta: float) -> void:
	if jani.direction != Vector2.ZERO:
		set_state(States.WALKING)

func _state_walking_process(_delta: float) -> void:
	if jani.direction == Vector2.ZERO:
		set_state(States.IDLE)

func _entered_state() -> void:
	match current_state:
		pass

func _physics_process(delta: float) -> void:
	match current_state:
		States.IDLE:
			_state_idle_process(delta)
		States.WALKING:
			_state_walking_process(delta)
