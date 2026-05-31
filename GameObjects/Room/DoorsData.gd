class_name DoorsData

enum LockTypes {
	NONE,
	RED,
	YELLOW,
	GREEN,
	BOARDED
}
var str_to_lock_type: Dictionary[String, LockTypes] = {
	"RED": LockTypes.RED,
	"YELLOW": LockTypes.YELLOW,
	"GREEN": LockTypes.GREEN,
	"BOARDED": LockTypes.BOARDED
}

signal unlocked(pos)

var grid_pos: Vector2i
var lock_type: LockTypes
var is_locked: bool

func initialize(pos: Vector2i, lock: String = "NONE") -> void:
	grid_pos = pos
	if str_to_lock_type.has(lock):
		lock_type = str_to_lock_type[lock]
		is_locked = true
	else:
		lock_type = LockTypes.NONE
		is_locked = false

func unlock() -> void:
	is_locked = false
	#lock_type = LockTypes.NONE
	unlocked.emit(grid_pos)

func clone() -> DoorsData:
	var copy = DoorsData.new()
	copy.grid_pos = grid_pos
	copy.lock_type = lock_type
	copy.is_locked = is_locked
	return copy
