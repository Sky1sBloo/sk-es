class_name TrapData

enum Types {
	SPIKED
}
var str_to_trap_type : Dictionary[String, Types] = {
	"SPIKED": Types.SPIKED
}

var grid_pos: Vector2i
var type: Types
var is_triggered: bool = false

signal triggered(grid_pos: Vector2i, type: Types)

func initialize(pos: Vector2i, trap_type: String) -> void:
	grid_pos = pos
	if str_to_trap_type.has(trap_type):
		type = str_to_trap_type[trap_type]
	else:
		type = Types.SPIKED

func trigger() -> void:
	is_triggered = true
	triggered.emit(grid_pos, type)

func clone() -> TrapData:
	var copy: = TrapData.new()
	copy.grid_pos = grid_pos
	copy.type = type
	copy.is_triggered = is_triggered
	return copy
