extends Control

@onready var trap_locations_lbl: = $TrapLocations
@onready var facts: = $Facts
@onready var inventory_lbl: = $Inventory

func _process(_delta: float) -> void:
	trap_locations_lbl.text = ""
	facts.text = ""
	inventory_lbl.text = ""
	var world: World = get_parent()
	for loc in world.jani.memory.trap_locations:
		trap_locations_lbl.text += str(loc) + "\n"
	
	for fact in world.jani.decision_manager.inference.get_facts_as_str():
		facts.text += fact + "\n"
	
	for item in world.jani.inventory.contents:
		inventory_lbl.text += Inventory.type_to_string(item) + "\n"
