extends Control

@onready var facts: = $Facts
@onready var inventory_lbl: = $Inventory
@onready var actions_lbl: = $Actions

func _process(_delta: float) -> void:
	facts.text = ""
	inventory_lbl.text = ""
	actions_lbl.text = ""
	var world: World = get_parent().get_parent()
	for fact in world.jani.decision_manager.inference.get_facts_as_str():
		facts.text += fact + "\n"
	
	for item in world.jani.inventory.contents:
		inventory_lbl.text += Inventory.type_to_string(item) + "\n"
	
	for action in world.jani.decision_manager.action_queue._heap:
		actions_lbl.text += Action.type_to_string(action.value.type) + " at " \
			+ str(action.value.grid_pos) + "\n"
