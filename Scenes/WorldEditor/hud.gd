extends Control
class_name EditorHud

@onready var cell_type_lbl: = $Details/CellType
@onready var contents_lbl: = $Details/Contents
@onready var world_selection: = $WorldSelection

@export var limit_handler: LimitHandler

@onready var wall_limit_lbl: = $LevelInfo/Limit/WallLimit
@onready var door_limit_lbl: = $LevelInfo/Limit/DoorLimit
@onready var container_limit_lbl: = $LevelInfo/Limit/ContainerLimit
@onready var trap_limit_lbl: = $LevelInfo/Limit/TrapLimit
@onready var furniture_limit_lbl: = $LevelInfo/Limit/FurnitureLimit

func update_contents(content: Array[Inventory.ItemType]) -> void:
	contents_lbl.text = "["
	for item in content:
		contents_lbl.text += Inventory.type_to_string(item) + ", "
	contents_lbl.text += "]"

func _on_world_editor_edit_selected(pos: Vector2i, room_details: RoomDetails) -> void:
	world_selection.item_selection.disabled = true
	world_selection.lock_selection.disabled = true
	
	contents_lbl.text = "[]"
	if room_details.room_layout[pos.y][pos.x] == 1:
		cell_type_lbl.text = "Wall"
		return
	
	if room_details.doors.has(pos):
		cell_type_lbl.text = "Door"
		_handle_door(room_details.doors[pos])
		world_selection.lock_selection.disabled = false
		return
	
	if room_details.containers.has(pos):
		cell_type_lbl.text = "Container"
		_handle_container(room_details.containers[pos])
		world_selection.item_selection.disabled = false
		return
	
	cell_type_lbl.text = "#"

func _handle_door(door: DoorsData) -> void:
	world_selection.lock_selection.select(door.lock_type)

func _handle_container(container: ContainerData) -> void:
	world_selection.selected_items = container.contains.duplicate_deep()
	update_contents(world_selection.selected_items)

func _on_world_selection_added_item(_selected_item: Inventory.ItemType) -> void:
	update_contents(world_selection.selected_items)

func _on_world_selection_removed_item() -> void:
	update_contents(world_selection.selected_items)


func _format_limit(limit_val: int) -> String:
	if limit_val == -1:
		return "∞"
	return str(limit_val)


func update_limits(limit_handler: LimitHandler, room_details: RoomDetails) -> void:
	# Ensure counts are up to date
	if limit_handler != null and room_details != null:
		limit_handler.update_counts_from_room(room_details)

	# Wall
	var wc: int = 0
	var wl: int = -1
	if limit_handler != null:
		wc = limit_handler.wall_count
		wl = limit_handler.wall_limit
	wall_limit_lbl.text = str(wc) + "/" + _format_limit(wl)

	# Door
	var dc: int = 0
	var dl: int = -1
	if limit_handler != null:
		dc = limit_handler.door_count
		dl = limit_handler.door_limit
	door_limit_lbl.text = str(dc) + "/" + _format_limit(dl)

	# Container
	var cc: int = 0
	var cl: int = -1
	if limit_handler != null:
		cc = limit_handler.container_count
		cl = limit_handler.container_limit
	container_limit_lbl.text = str(cc) + "/" + _format_limit(cl)

	# Trap
	var tc: int = 0
	var tl: int = -1
	if limit_handler != null:
		tc = limit_handler.trap_count
		tl = limit_handler.trap_limit
	trap_limit_lbl.text = str(tc) + "/" + _format_limit(tl)

	# Furniture
	var fc: int = 0
	var fl: int = -1
	if limit_handler != null:
		fc = limit_handler.furniture_count
		fl = limit_handler.furniture_limit
	furniture_limit_lbl.text = str(fc) + "/" + _format_limit(fl)
