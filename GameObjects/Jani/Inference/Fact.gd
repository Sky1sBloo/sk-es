class_name Fact

enum Type {
	HAS_ITEM,
	NEED_ITEM, # Inventory.ItemType
	MISSING_CRAFTABLE_ITEM, # [item, missing item]
	ITEM_STORED_AT, # [Vector2i, item
	ITEM_NEEDED_AT, # [Vector2i, Item]
	CRAFTABLE_ITEM, # Inventory.ItemType
	NEED_CRAFT, # Inventory.ItemType
	LOCKED_DOOR_AT,
	UNLOCKABLE_DOOR_AT, # Grid pos
	DOOR_KEY_TYPE_IS, # [ Vector2i, LockType]
	UNVISITED_DOOR_AT,
	UNVISITED_CONTAINER_AT, # Vector2i
	GET_OPEN_CONTAINER_AT, # Vector2i,
	FURNITURE_AT, # FurnitureData
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
	Type.MISSING_CRAFTABLE_ITEM: "MISSING_CRAFTABLE_ITEM",
	Type.ITEM_STORED_AT: "ITEM_STORED_AT",
	Type.ITEM_NEEDED_AT: "ITEM_NEEDED_AT",
	Type.CRAFTABLE_ITEM: "CRAFTABLE_ITEM",
	Type.NEED_CRAFT: "NEED_CRAFT",
	Type.LOCKED_DOOR_AT: "LOCKED_DOOR_AT",
	Type.UNLOCKABLE_DOOR_AT: "UNLOCKABLE_DOOR_AT",
	Type.DOOR_KEY_TYPE_IS: "DOOR_KEY_TYPE_IS",
	Type.UNVISITED_DOOR_AT: "UNVISITED_DOOR_AT",
	Type.UNVISITED_CONTAINER_AT: "UNVISITED_CONTAINER_AT",
	Type.GET_OPEN_CONTAINER_AT: "GET_OPEN_CONTAINER_AT",
	Type.FURNITURE_AT: "FURNITURE_AT",
	Type.FOUND_EXIT: "FOUND_EXIT"
}

static func type_to_string(t: Type) -> String:
	return _type_names.get(t, "UNKNOWN_TYPE")

func fact_to_string() -> String:
	var out: String = type_to_string(type) + " "
	match type:
		Type.HAS_ITEM, Type.NEED_ITEM, Type.CRAFTABLE_ITEM, Type.NEED_CRAFT:
			out += Inventory.type_to_string(args[0])
		Type.MISSING_CRAFTABLE_ITEM:
			out += Inventory.type_to_string(args[0]) + " missing " + Inventory.type_to_string(args[1])
		Type.ITEM_STORED_AT, Type.ITEM_NEEDED_AT:
			# [Vector2i, Item]
			out += str(args[0]) + ": " + Inventory.type_to_string(args[1])
		Type.DOOR_KEY_TYPE_IS:
			var lock = args[1]
			var lock_str := "UNKNOWN_LOCK"
			match lock:
				DoorsData.LockTypes.RED:
					lock_str = "RED"
				DoorsData.LockTypes.YELLOW:
					lock_str = "YELLOW"
				DoorsData.LockTypes.GREEN:
					lock_str = "GREEN"
				DoorsData.LockTypes.BOARDED:
					lock_str = "BOARDED"
				_:
					lock_str = str(lock)
			out += str(args[0]) + ": " + lock_str
		Type.FURNITURE_AT:
			var f: FurnitureData = args[0]
			var f_str := "UNKNOWN_FURNITURE"
			match f.type:
				FurnitureData.Types.TABLE:
					f_str = "TABLE"
			out += str(f.grid_pos) + ": " + f_str
		_:
			out += str(args)
	return out
