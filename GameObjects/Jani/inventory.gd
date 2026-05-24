extends Node
class_name Inventory

enum ItemType {
	NONE,
	RED_KEY,
	YELLOW_KEY,
	GREEN_KEY
}

var contents: Array[ItemType] = []

func push_item(item: ItemType) -> void:
	contents.push_back(item)

static var _item_type_str: Dictionary[ItemType, String] = {
	ItemType.NONE: "NONE",
	ItemType.RED_KEY: "RED_KEY",
	ItemType.YELLOW_KEY: "YELLOW_KEY",
	ItemType.GREEN_KEY: "GREEN_KEY"
}
static func type_to_string(t: ItemType) -> String:
	return _item_type_str.get(t, "UNKNOWN_TYPE")
