extends TileMapLayer
class_name TileMapDetails

enum DetailType {
	NONE,
	RED_LOCK,
	YELLOW_LOCK,
	GREEN_LOCK,
	BOARDED_DOOR,
	TABLE,
	CONTAINER,
	CONTAINER_OPENED,
	SPIKE_TRAP,
	UNKNOWN
}
static var details_atlas: Dictionary[DetailType, Vector2i] = {
	DetailType.NONE: Vector2i(14, 7),
	DetailType.RED_LOCK: Vector2i(1, 1),
	DetailType.YELLOW_LOCK: Vector2i(2, 1),
	DetailType.GREEN_LOCK: Vector2i(3, 1),
	DetailType.BOARDED_DOOR: Vector2i(2, 0),
	DetailType.TABLE: Vector2i(4, 0),
	DetailType.CONTAINER: Vector2i(5, 0),
	DetailType.CONTAINER_OPENED: Vector2i(6, 0),
	DetailType.SPIKE_TRAP: Vector2i(0, 2),
	DetailType.UNKNOWN: Vector2i(0, 1)
}

func set_cell_type(pos: Vector2i, detail_type: DetailType) -> void:
	set_cell(pos, 0, details_atlas[detail_type])

static func lock_type_to_detail(lock_type: DoorsData.LockTypes) -> DetailType:
	match lock_type:
		DoorsData.LockTypes.NONE:
			return DetailType.NONE
		DoorsData.LockTypes.RED:
			return DetailType.RED_LOCK
		DoorsData.LockTypes.YELLOW:
			return DetailType.YELLOW_LOCK
		DoorsData.LockTypes.GREEN:
			return DetailType.GREEN_LOCK
		DoorsData.LockTypes.BOARDED:
			return DetailType.BOARDED_DOOR
	return DetailType.UNKNOWN
