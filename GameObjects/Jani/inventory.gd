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
