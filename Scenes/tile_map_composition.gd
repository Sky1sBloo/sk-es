extends TileMapLayer
class_name TileMapComposition

enum CompositionType {
	NONE,
	WALL,
	DOOR,
	SPIKE,
	EXIT,
	START_POS
}

static var composition_atlas: Dictionary[CompositionType, Vector2i] = {
	CompositionType.NONE: Vector2i(14, 7),
	CompositionType.WALL: Vector2i(0, 0),
	CompositionType.DOOR: Vector2i(1, 0),
	CompositionType.SPIKE: Vector2i(3, 0),
	CompositionType.EXIT: Vector2i(0, 3),
	CompositionType.START_POS: Vector2i(0, 5)
}

func set_cell_type(pos: Vector2i, composition_type: CompositionType) -> void:
	set_cell(pos, 0, composition_atlas[composition_type])
