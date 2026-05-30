extends Node2D
class_name MainMenu

@onready var room_reader: RoomReader = $RoomReader

var world_editor: PackedScene = preload("res://Scenes/WorldEditor/world_editor.tscn")

func _on_sandbox_pressed() -> void:
	GameConfiguration.room_details = room_reader.get_level("res://Levels/Sandbox.json")
	get_tree().change_scene_to_packed(world_editor)
