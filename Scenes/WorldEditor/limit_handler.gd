extends Node
class_name LimitHandler

# Handles place limits
var wall_limit: int = -1
var door_limit: int = -1
var container_limit: int = -1
var trap_limit: int = -1
var furniture_limit: int = -1

var wall_count: int = 0
var door_count: int = 0
var container_count: int = 0
var trap_count: int = 0
var furniture_count: int = 0

signal limit_exceeded(pos: Vector2i, place_type)
signal counts_updated()
var room_details: RoomDetails = null
var _acc: float = 0.0
var _interval: float = 0.2

func set_room_details(rd: RoomDetails) -> void:
	room_details = rd
	# adopt limits from the room as authoritative when provided
	if rd != null and rd.limits != null and typeof(rd.limits) == TYPE_DICTIONARY:
		wall_limit = int(rd.limits.get("wall_limit", wall_limit))
		door_limit = int(rd.limits.get("door_limit", door_limit))
		container_limit = int(rd.limits.get("container_limit", container_limit))
		trap_limit = int(rd.limits.get("trap_limit", trap_limit))
		furniture_limit = int(rd.limits.get("furniture_limit", furniture_limit))
	# perform initial count
	update_counts_from_room(rd, false)


func _process(delta: float) -> void:
	if room_details == null:
		return
	_acc += delta
	if _acc >= _interval:
		_acc = 0.0
		# recompute counts periodically but don't emit to avoid recursion
		update_counts_from_room(room_details, false)

func can_place(place_type, room_details: RoomDetails = null) -> bool:
	# If room_details provided, recalc counts from it to avoid desync.
	if room_details != null:
		update_counts_from_room(room_details)
		# If the level defines limits, use them as authoritative
		if room_details.limits != null and typeof(room_details.limits) == TYPE_DICTIONARY:
			wall_limit = int(room_details.limits.get("wall_limit", wall_limit))
			door_limit = int(room_details.limits.get("door_limit", door_limit))
			container_limit = int(room_details.limits.get("container_limit", container_limit))
			trap_limit = int(room_details.limits.get("trap_limit", trap_limit))
			furniture_limit = int(room_details.limits.get("furniture_limit", furniture_limit))

	match place_type:
		WorldSelection.PlaceType.WALLS:
			return wall_limit < 0 or wall_count < wall_limit
		WorldSelection.PlaceType.DOORS:
			return door_limit < 0 or door_count < door_limit
		WorldSelection.PlaceType.CONTAINERS:
			return container_limit < 0 or container_count < container_limit
		WorldSelection.PlaceType.TRAP:
			return trap_limit < 0 or trap_count < trap_limit
		WorldSelection.PlaceType.TABLE:
			return furniture_limit < 0 or furniture_count < furniture_limit
		_:
			return true


func update_counts_from_room(room_details: RoomDetails, do_emit: bool = true) -> void:
	# Recompute all counts from the authoritative RoomDetails structure.
	var wc: int = 0
	if room_details.room_layout != null:
		for row in room_details.room_layout:
			for cell in row:
				if int(cell) == 1:
					wc += 1
	wall_count = wc

	door_count = 0
	if room_details.doors != null:
		door_count = room_details.doors.size()

	container_count = 0
	if room_details.containers != null:
		container_count = room_details.containers.size()

	trap_count = 0
	if room_details.traps != null:
		trap_count = room_details.traps.size()

	furniture_count = 0
	if room_details.furnitures != null:
		furniture_count = room_details.furnitures.size()

	# notify listeners that counts changed (optional)
	if do_emit:
		emit_signal("counts_updated")

func record_place(place_type, pos: Vector2i) -> void:
	# Increment the appropriate counter. If exceeding limit, emit signal and do not increment.
	match place_type:
		WorldSelection.PlaceType.WALLS:
			if wall_limit >= 0 and wall_count + 1 > wall_limit:
				emit_signal("limit_exceeded", pos, place_type)
				return
			wall_count += 1
		WorldSelection.PlaceType.DOORS:
			if door_limit >= 0 and door_count + 1 > door_limit:
				emit_signal("limit_exceeded", pos, place_type)
				return
			door_count += 1
		WorldSelection.PlaceType.CONTAINERS:
			if container_limit >= 0 and container_count + 1 > container_limit:
				emit_signal("limit_exceeded", pos, place_type)
				return
			container_count += 1
		WorldSelection.PlaceType.TRAP:
			if trap_limit >= 0 and trap_count + 1 > trap_limit:
				emit_signal("limit_exceeded", pos, place_type)
				return
			trap_count += 1
		WorldSelection.PlaceType.TABLE:
			if furniture_limit >= 0 and furniture_count + 1 > furniture_limit:
				emit_signal("limit_exceeded", pos, place_type)
				return
			furniture_count += 1

func record_delete(place_type) -> void:
	match place_type:
		WorldSelection.PlaceType.WALLS:
			wall_count = max(0, wall_count - 1)
		WorldSelection.PlaceType.DOORS:
			door_count = max(0, door_count - 1)
		WorldSelection.PlaceType.CONTAINERS:
			container_count = max(0, container_count - 1)
		WorldSelection.PlaceType.TRAP:
			trap_count = max(0, trap_count - 1)
		WorldSelection.PlaceType.TABLE:
			furniture_count = max(0, furniture_count - 1)

func _on_world_editor_placed_cell(pos: Vector2i, select: WorldSelection.PlaceType) -> void:
	# legacy signal handler: keep for compatibility but prefer direct calls
	# record placement using provided pos
	record_place(select, pos)

func _on_world_editor_deleted_cell(_pos: Vector2i, cell_type: WorldSelection.PlaceType) -> void:
	# legacy signal handler: decrement counts
	record_delete(cell_type)
