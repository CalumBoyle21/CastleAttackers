class_name ResourceNode
extends StaticBody3D

@export var resource_type: String = "wood"
@export var max_amount: int = 5
@export var respawn_time: float = 10.0

var amount_remaining: int

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	amount_remaining = max_amount
	WorldRegistry.register_resource_node(self)

func _exit_tree() -> void:
	WorldRegistry.unregister_resource_node(self)

func harvest() -> String:
	amount_remaining -= 1
	if amount_remaining <= 0:
		_deplete_and_respawn()
	return resource_type

func _deplete_and_respawn() -> void:
	visible = false
	await get_tree().create_timer(respawn_time).timeout
	amount_remaining = max_amount
	visible = true

func set_highlighted(value: bool) -> void:
	mesh_instance.material_overlay = HighlightUtil.get_material() if value else null
