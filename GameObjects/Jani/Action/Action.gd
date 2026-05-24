class_name Action

enum Types {
	VISIT_DOOR,
	OPEN_DOOR,
	OPEN_CONTAINER,
	CRAFT_ITEM,
	GO_TO_EXIT
}

var type: Types
var grid_pos: Vector2i
var interaction_pos: Vector2i = Vector2i(-1, -1) # No interaction
var args: Array = [] # For crafting and etc

var priority: float :
	get:
		return _action_priority[type]

var _action_priority: Dictionary[Types, float] = {
	Types.VISIT_DOOR: 10,
	Types.OPEN_DOOR: 15,
	Types.OPEN_CONTAINER: 5,
	Types.CRAFT_ITEM: 8,
	Types.GO_TO_EXIT: 99
}

static var _type_names := {
	Types.VISIT_DOOR: "VISIT_DOOR",
	Types.OPEN_DOOR: "OPEN_DOOR",
	Types.OPEN_CONTAINER: "OPEN_CONTAINER",
	Types.CRAFT_ITEM: "CRAFT_ITEM",
	Types.GO_TO_EXIT: "GO_TO_EXIT"
}

static func type_to_string(t: Types) -> String:
	return _type_names.get(t, "UNKNOWN")
