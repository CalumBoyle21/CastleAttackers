extends Node3D

## Since the player's mouse is captured for camera-look, "hovering" is
## done via a screen-center raycast (a crosshair) instead of the OS
## cursor position. Anything hit that implements set_highlighted() glows.
## Left-click acts on whatever's hovered: toggles a villager's
## Idle/Gather state, or opens/closes a drop-off's inventory panel.

@export var interact_distance: float = 15.0

var camera: Camera3D = null
var hovered_target: Node3D = null

@onready var crosshair: Control = %Crosshair
@onready var inventory_panel: Control = %InventoryPanel
@onready var build_controller: Node = $"../BuildController"

func _physics_process(_delta: float) -> void:
	if camera == null:
		camera = get_viewport().get_camera_3d()
		if camera == null:
			return
	_update_hover()

func _update_hover() -> void:
	var viewport := get_viewport()
	var screen_center: Vector2 = viewport.get_visible_rect().size / 2.0
	var from: Vector3 = camera.project_ray_origin(screen_center)
	var to: Vector3 = from + camera.project_ray_normal(screen_center) * interact_distance

	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var result := space_state.intersect_ray(query)

	var new_hover: Node3D = null
	if result and result.collider is Node3D and result.collider.has_method("set_highlighted"):
		new_hover = result.collider

	if new_hover != hovered_target:
		if hovered_target:
			hovered_target.set_highlighted(false)
		hovered_target = new_hover
		if hovered_target:
			hovered_target.set_highlighted(true)
		crosshair.set_active(hovered_target != null)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	if build_controller.is_active():
		return  # BuildController handles "interact" itself while placing posts

	if hovered_target is VillagerAgent:
		hovered_target.toggle_idle_gather()
	elif hovered_target is DropOffPoint:
		if inventory_panel.is_open():
			inventory_panel.close()
		else:
			inventory_panel.open_for(hovered_target)
	elif hovered_target is WallEdge:
		hovered_target.try_add_board()
