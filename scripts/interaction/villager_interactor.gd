extends Node3D

## Since the player's mouse is captured for camera-look, "hovering" is
## done via a screen-center raycast (a crosshair) instead of the OS
## cursor position. Anything hit that implements set_highlighted() glows;
## left-click additionally toggles a hovered villager between Idle/Gather.

@export var interact_distance: float = 15.0

var camera: Camera3D = null
var hovered_target: Node3D = null

@onready var crosshair: Control = %Crosshair

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
	if event.is_action_pressed("interact") and hovered_target is VillagerAgent:
		hovered_target.toggle_idle_gather()
