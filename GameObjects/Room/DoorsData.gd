class_name DoorsData

enum LockTypes {
	NONE,
	RED,
	GREEN,
	YELLOW
}
var str_to_lock_type: Dictionary[String, LockTypes] = {
	"RED": LockTypes.RED,
	"GREEN": LockTypes.GREEN,
	"YELLOW": LockTypes.YELLOW
}

signal unlocked(pos)

var grid_pos: Vector2i
var lock_type: LockTypes
var is_locked: bool

func initialize(pos: Vector2i, lock: String) -> void:
	grid_pos = pos
	if str_to_lock_type.has(lock):
		lock_type = str_to_lock_type[lock]
	else:
		lock_type = LockTypes.NONE
	is_locked = true

func unlock_door() -> void:
	is_locked = false
	unlocked.emit(grid_pos)
