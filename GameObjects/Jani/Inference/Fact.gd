class_name Fact

enum Type {
	HAS_ITEM,
	NEED_ITEM, # Inventory.ItemType
	ITEM_STORED_AT,
	LOCKED_DOOR_AT,
	UNLOCKABLE_DOOR_AT, # Grid pos
	DOOR_KEY_TYPE_IS,
	UNVISITED_DOOR_AT,
	UNVISITED_CONTAINER_AT, # Vector2i
	GET_OPEN_CONTAINER_AT, # Vector2i
	FOUND_EXIT, # Vector2i
}

var type: Type
var args: Array = []

func initialize(new_type: Type, arg: Array) -> void:
	type = new_type
	args = arg

static var _type_names := {
	Type.HAS_ITEM: "HAS_ITEM",
	Type.NEED_ITEM: "NEED_ITEM",
	Type.ITEM_STORED_AT: "ITEM_STORED_AT",
	Type.LOCKED_DOOR_AT: "LOCKED_DOOR_AT",
	Type.UNLOCKABLE_DOOR_AT: "UNLOCKABLE_DOOR_AT",
	Type.DOOR_KEY_TYPE_IS: "DOOR_KEY_TYPE_IS",
	Type.UNVISITED_DOOR_AT: "UNVISITED_DOOR_AT",
	Type.UNVISITED_CONTAINER_AT: "UNVISITED_CONTAINER_AT",
	Type.GET_OPEN_CONTAINER_AT: "GET_OPEN_CONTAINER_AT",
	Type.FOUND_EXIT: "FOUND_EXIT"
}

static func type_to_string(t: Type) -> String:
	return _type_names.get(t, "UNKNOWN_TYPE")
