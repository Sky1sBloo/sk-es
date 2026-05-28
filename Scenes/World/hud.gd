extends Control

@onready var trap_locations_lbl: = $TrapLocations
@onready var facts: = $Facts
@onready var inventory_lbl: = $Inventory
@onready var actions_lbl: = $Actions

func _process(_delta: float) -> void:
	trap_locations_lbl.text = ""
	facts.text = ""
	inventory_lbl.text = ""
	actions_lbl.text = ""
	var world: World = get_parent()
	for loc in world.jani.memory.trap_locations:
		trap_locations_lbl.text += str(loc) + "\n"
	
	for fact in world.jani.decision_manager.inference.get_facts_as_str():
		facts.text += fact + "\n"
	
	for item in world.jani.inventory.contents:
		inventory_lbl.text += Inventory.type_to_string(item) + "\n"
	
	for action in world.jani.decision_manager.action_queue._heap:
		actions_lbl.text += Action.type_to_string(action.value.type) + " at " \
			+ str(action.value.grid_pos) + "\n"
