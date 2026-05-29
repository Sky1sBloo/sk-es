extends Control
class_name WorldSelection

enum PlaceType {
	WALLS,
	DOORS,
	CONTAINERS,
	TRAP
}

var place_type: PlaceType : 
	get:
		return place_selection.selected

@onready var place_selection: = $PlaceSelection
