class_name ContainerData

enum Types {
	DRAWER
}

enum ItemType {
	NONE,
	RED_KEY,
	YELLOW_KEY,
	GREEN_KEY
}

var grid_pos: Vector2i
var type: Types
var contains: ItemType

func initialize(pos: Vector2i, cont_type: Types, item: ItemType) -> void:
	grid_pos = pos
	type = cont_type
	contains = item
