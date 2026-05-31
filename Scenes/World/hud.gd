extends Control

@onready var facts: = $Facts
@onready var actions_lbl: = $Actions
@onready var inventory_list: = $InventoryList
@onready var objectives_lbl: = $Objectives
@onready var objectives_hdr: = $ObjectivesHeading
@onready var result: = $Result
@onready var passed_lbl:= $Result/PassedLabel

var _passed: bool =false

func _on_goal_counter_objectives_completed() -> void:
	objectives_hdr.modulate = Color(1, 1, 0, 1)
	objectives_lbl.modulate = Color(1, 1, 0, 1)
	_passed = true

func _on_interaction_handler_exit_reached() -> void:
	show_passed(_passed)

func show_passed(passed: bool) -> void:
	result.visible = true
	if passed:
		passed_lbl.text = "PASSED!"
		passed_lbl.modulate = Color(1, 1, 0, 1)
	else:
		passed_lbl.text = "FAILED!"
		passed_lbl.modulate = Color(1, 0, 0, 1)


func _process(_delta: float) -> void:
	facts.text = ""
	actions_lbl.text = ""
	var world: World = get_parent().get_parent()
	for fact in world.jani.decision_manager.inference.get_facts_as_str():
		facts.text += fact + "\n"
	
	_load_inventory_list(world.jani.inventory)
	
	for action in world.jani.decision_manager.action_queue._heap:
		actions_lbl.text += Action.type_to_string(action.value.type) + " at " \
			+ str(action.value.grid_pos) + "\n"

	# Objectives and their current progress
	objectives_lbl.text = ""
	var gc: GoalCounter = world.goal_counter
	if gc != null and gc.goals.size() > 0:
		# show room objective description first (if present)
		if world.room != null and world.room.room_details != null and world.room.room_details.objective != "":
			objectives_lbl.text = world.room.room_details.objective + "\n\n"
		for key in gc.goals.keys():
			var required = int(gc.goals[key])
			var current = 0
			match key:
				"interaction_count":
					current = gc.interaction_count
				"move_count":
					current = gc.move_count
				"container_checked":
					current = gc.container_checked
				"door_opened":
					current = gc.door_opened
				"trap_triggered":
					current = gc.trap_triggered
				"cost_reached":
					current = gc.action_cost
				"crafted_item":
					current = gc.crafted_item
				_:
					continue
			var label = GoalCounter.goal_key_to_str(key)
			objectives_lbl.text += label + str(current)
			objectives_lbl.text += " / " + str(required)
			objectives_lbl.text += "\n"

func _load_inventory_list(inventory: Inventory) -> void:
	inventory_list.clear()
	for item in inventory.contents:
		inventory_list.add_icon_item(load(_item_to_tex[item]))

# Path to texture sprite
static var _item_to_tex: Dictionary[Inventory.ItemType, String] = {
	Inventory.ItemType.RED_KEY: "res://Sprites/Items/RedKey.png",
	Inventory.ItemType.YELLOW_KEY: "res://Sprites/Items/YellowKey.png",
	Inventory.ItemType.GREEN_KEY: "res://Sprites/Items/GreenKey.png",
	Inventory.ItemType.AXE: "res://Sprites/Items/Axe.png",
	Inventory.ItemType.AXE_HEAD: "res://Sprites/Items/AxeHead.png",
	Inventory.ItemType.STICK: "res://Sprites/Items/Stick.png",
	Inventory.ItemType.ROPE: "res://Sprites/Items/Rope.png"
}
