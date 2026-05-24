extends Node
class_name Inventory

@export var memory: JaniMemory

enum ItemType {
	NONE,
	RED_KEY,
	YELLOW_KEY,
	GREEN_KEY,
	AXE,
	AXE_HEAD,
	STICK,
	ROPE
}

var contents: Array[ItemType] = []

func push_item(item: ItemType) -> void:
	contents.push_back(item)

static var _item_type_str: Dictionary[ItemType, String] = {
	ItemType.NONE: "NONE",
	ItemType.RED_KEY: "RED_KEY",
	ItemType.YELLOW_KEY: "YELLOW_KEY",
	ItemType.GREEN_KEY: "GREEN_KEY",
	ItemType.AXE: "AXE",
	ItemType.AXE_HEAD: "AXE_HEAD",
	ItemType.STICK: "STICK",
	ItemType.ROPE: "ROPE"
}
static func type_to_string(t: ItemType) -> String:
	return _item_type_str.get(t, "UNKNOWN_TYPE")

func craft_item(item: Inventory.ItemType) -> void:
	var recipe: = memory.get_recipe(item)
	if not recipe.is_craftable(contents):
		print("not craftable recipe")
		return
	
	push_item(recipe.item)
	var to_delete: Array[ItemType] = []
	for requirement in recipe.requirements:
		to_delete.push_back(requirement)
	
	for del in to_delete:
		contents.erase(del)
