extends Control
class_name EditorHud

@onready var cell_type_lbl: = $Details/CellType
@onready var contents_lbl: = $Details/Contents
@onready var world_selection: = $WorldSelection

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
