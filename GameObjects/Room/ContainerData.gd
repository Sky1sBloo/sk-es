class_name ContainerData

enum Types {
	DRAWER
}
var str_to_container_type: Dictionary[String, Types] = {
	"DRAWER": Types.DRAWER
}

enum ItemType {
	NONE,
	RED_KEY,
	YELLOW_KEY,
	GREEN_KEY
}

var grid_pos: Vector2i
var type: Types
var contains: Array[ItemType]

func initialize(pos: Vector2i, cont_type: String, items: Array[String]) -> void:
	grid_pos = pos
	if str_to_container_type.has(cont_type):
		type = str_to_container_type[cont_type]
	else:
		type = Types.DRAWER
	# contains = items
