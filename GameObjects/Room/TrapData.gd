class_name TrapData

enum Types {
	SPIKED
}
var str_to_trap_type : Dictionary[String, Types] = {
	"SPIKED": Types.SPIKED
}

var grid_pos: Vector2i
var type: Types

func initialize(pos: Vector2i, trap_type: String) -> void:
	grid_pos = pos
	if str_to_trap_type.has(trap_type):
		type = str_to_trap_type[trap_type]
	else:
		type = Types.SPIKED
