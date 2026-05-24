class_name FurnitureData

enum Types {
	TABLE
}

var grid_pos: Vector2i
var type: Types

static var str_to_type: Dictionary[String, Types] = {
	"TABLE": Types.TABLE
}

func initialize(pos: Vector2i, new_type: String) -> void:
	grid_pos = pos
	type = str_to_type[new_type]
