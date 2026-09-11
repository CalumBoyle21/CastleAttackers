class_name VillagerAgent
extends CharacterBody3D

const SPEED: float = 3.0
const ARRIVE_DISTANCE: float = 0.4
const GATHER_DURATION: float = 2.0
const DELIVER_DURATION: float = 0.5

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var carrying_resource: String = ""
var target_resource_node: Node3D = null
var target_drop_off: Node3D = null
var home_position: Vector3

var move_target: Vector3 = Vector3.ZERO
var has_move_target: bool = false

@onready var visual: Node3D = $Visual
@onready var mesh_instance: MeshInstance3D = $Visual/MeshInstance3D
@onready var state_machine: AgentStateMachine = $StateMachine

func _ready() -> void:
	home_position = global_position

## Called once per physics tick by the StateMachine, after the current
## state has had a chance to set velocity.x/z via move_along_path().
func physics_step(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()

func set_move_target(target: Vector3) -> void:
	move_target = target
	has_move_target = true

func has_reached_target() -> bool:
	if not has_move_target:
		return true
	return _flat_distance_to(move_target) <= ARRIVE_DISTANCE

## Steers in a straight line toward move_target and faces the visual mesh
## toward the direction of travel. Does not call move_and_slide() itself.
## Direct-line movement is enough while the world is one open flat plane;
## swap this for NavigationAgent3D pathing once obstacles/buildings exist.
func move_along_path(delta: float) -> void:
	if not has_move_target or _flat_distance_to(move_target) <= ARRIVE_DISTANCE:
		has_move_target = false
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		return

	var direction: Vector3 = move_target - global_position
	direction.y = 0
	direction = direction.normalized()
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	var target_angle: float = atan2(direction.x, direction.z)
	visual.rotation.y = lerp_angle(visual.rotation.y, target_angle, delta * 10.0)

func _flat_distance_to(point: Vector3) -> float:
	var flat_pos := Vector3(global_position.x, 0, global_position.z)
	var flat_point := Vector3(point.x, 0, point.z)
	return flat_pos.distance_to(flat_point)

func set_highlighted(value: bool) -> void:
	mesh_instance.material_overlay = HighlightUtil.get_material() if value else null

## Manually forces the villager between Idle and Gather, bypassing the
## normal Wander gate. Used by the hover/click interactor.
func toggle_idle_gather() -> void:
	if state_machine.current_state and state_machine.current_state.name == "Idle":
		state_machine.change_state("Gather")
	else:
		state_machine.change_state("Idle")
