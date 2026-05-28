extends Node2D
class_name InventoryCollectionAnimation

@onready var sprite: = $Offset/AnimatedSprite2D
@onready var anim_player: = $AnimationPlayer

func play(pos: Vector2, item: Inventory.ItemType):
	$Offset.global_position = pos
	set_sprite(item)
	anim_player.play("display")

func set_sprite(item: Inventory.ItemType) -> void:
	match item:
		Inventory.ItemType.AXE:
			sprite.play("axe")
		Inventory.ItemType.AXE_HEAD:
			sprite.play("axe_head")
		Inventory.ItemType.GREEN_KEY:
			sprite.play("green_key")
		Inventory.ItemType.YELLOW_KEY:
			sprite.play("yellow_key")
		Inventory.ItemType.RED_KEY:
			sprite.play("red_key")
		Inventory.ItemType.ROPE:
			sprite.play("rope")
		Inventory.ItemType.STICK:
			sprite.play("stick")
		_:
			sprite.stop()
