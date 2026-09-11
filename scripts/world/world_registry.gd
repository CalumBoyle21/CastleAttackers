extends Node

## Autoload singleton. World objects (ResourceNode, DropOffPoint, ...)
## register themselves here so agents can query "nearest X" without
## holding direct references to specific scene instances.

var resource_nodes: Array = []
var drop_off_points: Array = []

func register_resource_node(node: Node3D) -> void:
	resource_nodes.append(node)

func unregister_resource_node(node: Node3D) -> void:
	resource_nodes.erase(node)

func register_drop_off(node: Node3D) -> void:
	drop_off_points.append(node)

func unregister_drop_off(node: Node3D) -> void:
	drop_off_points.erase(node)

func has_available_resource() -> bool:
	for node in resource_nodes:
		if is_instance_valid(node) and node.amount_remaining > 0:
			return true
	return false

func get_nearest_resource_node(from_position: Vector3) -> Node3D:
	var nearest: Node3D = null
	var nearest_dist: float = INF
	for node in resource_nodes:
		if not is_instance_valid(node) or node.amount_remaining <= 0:
			continue
		var dist: float = from_position.distance_squared_to(node.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = node
	return nearest

func get_nearest_drop_off(from_position: Vector3) -> Node3D:
	var nearest: Node3D = null
	var nearest_dist: float = INF
	for node in drop_off_points:
		if not is_instance_valid(node):
			continue
		var dist: float = from_position.distance_squared_to(node.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = node
	return nearest
