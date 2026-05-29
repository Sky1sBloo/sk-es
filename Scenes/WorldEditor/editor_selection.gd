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
	TRAP
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

signal added_item(selected_item: Inventory.ItemType)
signal removed_item()

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
