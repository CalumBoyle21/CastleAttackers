class_name DropOffPoint
extends StaticBody3D

signal inventory_changed

var deposited: Dictionary = {}

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	WorldRegistry.register_drop_off(self)

func _exit_tree() -> void:
	WorldRegistry.unregister_drop_off(self)

func deposit(resource_type: String) -> void:
	deposited[resource_type] = deposited.get(resource_type, 0) + 1
	inventory_changed.emit()
	print("Delivered %s (total: %d)" % [resource_type, deposited[resource_type]])

func can_afford(costs: Dictionary) -> bool:
	for resource_type in costs:
		if deposited.get(resource_type, 0) < costs[resource_type]:
			return false
	return true

func spend(costs: Dictionary) -> bool:
	if not can_afford(costs):
		return false
	for resource_type in costs:
		deposited[resource_type] -= costs[resource_type]
		if deposited[resource_type] <= 0:
			deposited.erase(resource_type)
	inventory_changed.emit()
	return true

func craft(recipe: Dictionary) -> bool:
	if not spend(recipe.get("costs", {})):
		return false
	var output: String = recipe.get("output", "")
	var output_amount: int = recipe.get("output_amount", 1)
	deposited[output] = deposited.get(output, 0) + output_amount
	inventory_changed.emit()
	return true

func set_highlighted(value: bool) -> void:
	mesh_instance.material_overlay = HighlightUtil.get_material() if value else null
