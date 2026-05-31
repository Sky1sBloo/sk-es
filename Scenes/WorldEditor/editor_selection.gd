extends Node
class_name WorldSelection

enum ModeType {
	PLACE,
	EDIT
}

enum PlaceType {
	WALLS,
	DOORS,
	CONTAINERS,
	SPIKE,
	GLUE,
	TABLE,
	EXIT,
	START_POS
}

var mode_type: ModeType :
	get:
		return mode_selection.selected

var place_type: PlaceType : 
	get:
		return place_selection.selected

var lock_type: DoorsData.LockTypes :
	get:
		return lock_selection.selected

var selected_items: Array[Inventory.ItemType] = []

@onready var place_selection: = $PlaceSelection
@onready var lock_selection: = $LockSelection
@onready var mode_selection: = $ModeSelection
@onready var item_selection: = $ItemSelection

@onready var add_item: = $AddItem
@onready var delete_item: = $DeleteItem
signal added_item(selected_item: Inventory.ItemType)
signal removed_item()

func _process(_delta: float) -> void:
	if mode_type == ModeType.PLACE:
		item_selection.disabled = true
		lock_selection.disabled = true
	
	add_item.disabled = item_selection.disabled
	delete_item.disabled = item_selection.disabled

func is_selecting() -> bool:
	return place_selection.get_popup().visible or \
		lock_selection.get_popup().visible or \
		mode_selection.get_popup().visible or \
		item_selection.get_popup().visible

func _on_add_item_pressed() -> void:
	var item_selected: Inventory.ItemType = item_selection.selected
	if item_selected == Inventory.ItemType.NONE:
		return
	selected_items.push_back(item_selected)
	added_item.emit(item_selected)


func _on_delete_item_pressed() -> void:
	if selected_items.is_empty():
		return
	selected_items.pop_back()
	removed_item.emit()
