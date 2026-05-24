extends Control

@onready var trap_locations_lbl: = $TrapLocations
@onready var facts: = $Facts

func _process(_delta: float) -> void:
	trap_locations_lbl.text = ""
	facts.text = ""
	var world: World = get_parent()
	for loc in world.jani.memory.trap_locations:
		trap_locations_lbl.text += str(loc) + "\n"
	
	for fact in world.jani.decision_manager.inference.get_facts_as_str():
		facts.text += fact + "\n"
