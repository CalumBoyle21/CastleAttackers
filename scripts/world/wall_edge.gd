class_name WallEdge
extends StaticBody3D

const MAX_BOARDS: int = 3
const BOARD_LENGTH: float = BuildGrid.CELL_SIZE
const BOARD_THICKNESS: float = 0.15
const BOARD_HEIGHT: float = 0.3
const BOARD_Y_START: float = 0.3
const BOARD_Y_STEP: float = 0.4

## Collision layer bit that makes this edge physically block movement
## (same layer Post/Ground use). Not part of the base collision_layer
## set in WallEdge.tscn — an empty edge (0 boards) stays walk-through
## and is only hoverable/clickable; this bit gets added the moment the
## first board is placed.
const BLOCKING_LAYER_BIT: int = 1

var post_a: Post
var post_b: Post
var board_count: int = 0

@onready var boards_container: Node3D = $BoardsContainer
@onready var hover_indicator: MeshInstance3D = $HoverIndicator

## Must be called before add_child()!!!
func setup(a: Post, b: Post) -> void:
	post_a = a
	post_b = b
	position = (a.position + b.position) / 2.0
	var offset: Vector3 = b.position - a.position
	rotation.y = 0.0 if absf(offset.x) > absf(offset.z) else deg_to_rad(90.0)

func is_complete() -> bool:
	return board_count >= MAX_BOARDS

func try_add_board() -> bool:
	if is_complete():
		return false
	var drop_off := WorldRegistry.get_nearest_drop_off(global_position)
	if drop_off == null or not drop_off.spend({"board": 1}):
		return false
	board_count += 1
	if board_count == 1:
		collision_layer |= BLOCKING_LAYER_BIT
	_add_board_mesh()
	return true

func _add_board_mesh() -> void:
	var board_mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(BOARD_LENGTH, BOARD_HEIGHT, BOARD_THICKNESS)
	board_mesh.mesh = box
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.55, 0.35, 0.15, 1)
	board_mesh.material_override = material
	board_mesh.position = Vector3(0, BOARD_Y_START + BOARD_Y_STEP * (board_count - 1), 0)
	boards_container.add_child(board_mesh)

func set_highlighted(value: bool) -> void:
	hover_indicator.material_overlay = HighlightUtil.get_material() if value else null
