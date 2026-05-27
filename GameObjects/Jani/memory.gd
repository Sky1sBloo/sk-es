extends Node
class_name JaniMemory

# Used only for pathfinding and not decision making
var env_layout: Array = []
var exit_locations: Array[Vector2i] = []

# Used for interaction only
var room_details: RoomDetails

var locked_door_locations: Array[Vector2i] = []  # Locked doors
var door_lock_type: Dictionary[Vector2i, DoorsData.LockTypes]
var trap_locations: Array[Vector2i] = []

var container_locations: Array[Vector2i] = [] 
var furnitures: Array[FurnitureData] = []
var unopened_container_locations: Array[Vector2i] = []

var item_locations: Array[Array] = [] # Inside array contains [Vector2i gridpos, item type]

var recipes: Dictionary[Inventory.ItemType, Recipe]

func _ready() -> void:
	load_recipes()

func initialize(details: RoomDetails) -> void:
	# Initialize memory from RoomDetails (overwrites any existing env_layout)
	env_layout = []
	for row in details.room_layout:
		# duplicate rows to avoid referencing the original
		var new_row: Array = []
		for cell in row:
			new_row.push_back(cell)
		env_layout.push_back(new_row)
	room_details = details

func rebind(details: RoomDetails) -> void:
	# Rebind memory to a new RoomDetails while preserving learned data
	var new_layout: Array = []
	for row in details.room_layout:
		var new_row: Array = []
		for cell in row:
			new_row.push_back(cell)
		new_layout.push_back(new_row)
	# Overlay previously learned traps so they remain marked as walls
	for pos in trap_locations:
		if pos.y >= 0 and pos.y < new_layout.size() and pos.x >= 0 and pos.x < new_layout.front().size():
			new_layout[pos.y][pos.x] = 1
	
	env_layout = new_layout
	room_details = details

func add_trap(pos: Vector2i) -> void:
	env_layout[pos.y][pos.x] = 1
	trap_locations.push_back(pos)

func load_recipes() -> void:
	var axe_recipe: = Recipe.new()
	axe_recipe.define(Inventory.ItemType.AXE, [
		Inventory.ItemType.AXE_HEAD,
		Inventory.ItemType.STICK,
		Inventory.ItemType.ROPE
	])
	recipes[Inventory.ItemType.AXE] = axe_recipe

func get_recipe(item: Inventory.ItemType) -> Recipe:
	if not recipes.has(item):
		return null
	
	return recipes[item]
