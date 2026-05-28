class_name Recipe

var item: Inventory.ItemType
var requirements: Array[Inventory.ItemType]

func define(to_craft: Inventory.ItemType, req: Array[Inventory.ItemType] = []):
	item = to_craft
	requirements = req

func is_craftable(contents: Array[Inventory.ItemType]) -> bool:
	var requirements_met: Array[bool] = []
	for i in range(requirements.size()):
		requirements_met.push_back(false)
	
	for content in contents:
		for i in range(requirements.size()):
			if requirements[i] == content:
				requirements_met[i] = true
	
	var not_craftable: bool = false
	for met in requirements_met:
		if not met:
			not_craftable = true
	return not not_craftable
