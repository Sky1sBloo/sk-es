class_name ContainerData

enum Types {
	DRAWER
}
var str_to_container_type: Dictionary[String, Types] = {
	"DRAWER": Types.DRAWER
}

var str_to_item_type: Dictionary[String, Inventory.ItemType] = {
	"RED_KEY": Inventory.ItemType.RED_KEY,
	"YELLOW_KEY": Inventory.ItemType.YELLOW_KEY,
	"GREEN_KEY": Inventory.ItemType.GREEN_KEY
}

var grid_pos: Vector2i
var type: Types
var contains: Array[Inventory.ItemType] = []
var is_opened: bool = false

func initialize(pos: Vector2i, cont_type: String, items: Array[String]) -> void:
	is_opened = false
	grid_pos = pos
	if str_to_container_type.has(cont_type):
		type = str_to_container_type[cont_type]
	else:
		type = Types.DRAWER
	for item in items:
		if str_to_item_type.has(item):
			contains.push_back(str_to_item_type[item])
		else:
			printerr("Unkown item: ", item)
