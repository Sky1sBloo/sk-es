extends Control

@onready var facts: = $Facts
@onready var actions_lbl: = $Actions
@onready var inventory_list: = $InventoryList

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
