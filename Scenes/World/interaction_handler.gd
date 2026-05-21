extends Node
class_name InteractionHandler

var jani: Jani
var room: Room
@onready var world: World = get_parent()

func initialize(jani_node: Jani, room_node: Room) -> void:
	jani = jani_node
	room = room_node

func _on_jani_move_finished(pos: Vector2i) -> void:
	if room.room_details.is_cell_trap(pos):
		world.reset()
		jani.memory.add_trap(pos)
		print("stood on trap", pos)
