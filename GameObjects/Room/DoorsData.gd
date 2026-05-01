class_name DoorsData

enum LockTypes {
	NONE,
	RED,
	GREEN,
	YELLOW
}

var grid_pos: Vector2i
var lock_type: LockTypes
var is_locked: bool

func initialize(pos: Vector2i, lock: LockTypes) -> void:
	grid_pos = pos
	lock_type = lock
	is_locked = true

func unlock_door() -> void:
	is_locked = false
