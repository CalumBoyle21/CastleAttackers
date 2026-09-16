extends Node

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

var posts: Dictionary = {}    # Vector2i cell -> Post
var edges: Dictionary = {}    # String edge key -> WallEdge

func register_post(cell: Vector2i, post: Node3D) -> void:
	posts[cell] = post

func unregister_post(cell: Vector2i) -> void:
	posts.erase(cell)

func get_post_at(cell: Vector2i) -> Node3D:
	return posts.get(cell)

func _edge_key(cell_a: Vector2i, cell_b: Vector2i) -> String:
	if cell_a.x < cell_b.x or (cell_a.x == cell_b.x and cell_a.y < cell_b.y):
		return "%d,%d|%d,%d" % [cell_a.x, cell_a.y, cell_b.x, cell_b.y]
	return "%d,%d|%d,%d" % [cell_b.x, cell_b.y, cell_a.x, cell_a.y]

func register_edge(cell_a: Vector2i, cell_b: Vector2i, edge: Node3D) -> void:
	edges[_edge_key(cell_a, cell_b)] = edge

func get_edge(cell_a: Vector2i, cell_b: Vector2i) -> Node3D:
	return edges.get(_edge_key(cell_a, cell_b))

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
