extends Node3D

@export var post_scene: PackedScene
@export var wall_edge_scene: PackedScene
@export var max_build_distance: float = 8.0

@onready var hotbar: Control = %Hotbar

var camera: Camera3D = null
var build_mode_active: bool = false
var current_cell: Vector2i = Vector2i.ZERO
var current_cell_valid: bool = false

var _ghost: MeshInstance3D = null
var _ghost_material: StandardMaterial3D = null

func is_active() -> bool:
	return build_mode_active

func _physics_process(_delta: float) -> void:
	if camera == null:
		camera = get_viewport().get_camera_3d()
		if camera == null:
			return

	var should_be_active: bool = hotbar.is_selected_placeable()
	if should_be_active != build_mode_active:
		build_mode_active = should_be_active
		if build_mode_active:
			_create_ghost()
		else:
			_destroy_ghost()

	if build_mode_active:
		_update_ghost()

func _unhandled_input(event: InputEvent) -> void:
	if build_mode_active and event.is_action_pressed("interact"):
		_try_place_post()
		get_viewport().set_input_as_handled()

func _create_ghost() -> void:
	_ghost = MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.15
	mesh.bottom_radius = 0.15
	mesh.height = 1.5
	_ghost.mesh = mesh
	_ghost_material = StandardMaterial3D.new()
	_ghost_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_ghost_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_ghost.material_override = _ghost_material
	add_child(_ghost)

func _destroy_ghost() -> void:
	if _ghost:
		_ghost.queue_free()
		_ghost = null
		_ghost_material = null

func _update_ghost() -> void:
	var viewport := get_viewport()
	var screen_center: Vector2 = viewport.get_visible_rect().size / 2.0
	var origin: Vector3 = camera.project_ray_origin(screen_center)
	var dir: Vector3 = camera.project_ray_normal(screen_center)

	if absf(dir.y) < 0.0001:
		_ghost.visible = false
		return
	var t: float = -origin.y / dir.y
	if t <= 0.0:
		_ghost.visible = false
		return

	var hit_point: Vector3 = origin + dir * t
	current_cell = BuildGrid.world_to_cell(hit_point)
	var cell_world: Vector3 = BuildGrid.cell_to_world(current_cell)

	var within_range: bool = global_position.distance_to(cell_world) <= max_build_distance
	var empty: bool = WorldRegistry.get_post_at(current_cell) == null
	current_cell_valid = within_range and empty

	_ghost.visible = true
	_ghost.global_position = cell_world + Vector3(0, 0.75, 0)
	_ghost_material.albedo_color = Color(0.2, 1.0, 0.2, 0.5) if current_cell_valid else Color(1.0, 0.2, 0.2, 0.5)

func _try_place_post() -> void:
	if not current_cell_valid:
		return
	var cell_world: Vector3 = BuildGrid.cell_to_world(current_cell)
	var drop_off := WorldRegistry.get_nearest_drop_off(cell_world)
	if drop_off == null or not drop_off.spend({"post": 1}):
		return

	var post: Post = post_scene.instantiate()
	post.setup(current_cell)
	_build_objects_container().add_child(post)
	_connect_neighbors(post)

func _connect_neighbors(post: Post) -> void:
	for offset in BuildGrid.NEIGHBOR_OFFSETS:
		var neighbor_cell: Vector2i = post.cell + offset
		var neighbor: Node = WorldRegistry.get_post_at(neighbor_cell)
		if neighbor and WorldRegistry.get_edge(post.cell, neighbor_cell) == null:
			var edge: WallEdge = wall_edge_scene.instantiate()
			edge.setup(post, neighbor)
			_build_objects_container().add_child(edge)
			WorldRegistry.register_edge(post.cell, neighbor_cell, edge)

func _build_objects_container() -> Node3D:
	return get_tree().current_scene.get_node("BuildObjects")
