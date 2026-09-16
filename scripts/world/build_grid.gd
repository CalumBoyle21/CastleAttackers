class_name BuildGrid

## Shared grid math for post placement. Posts snap to CELL_SIZE-spaced
## world points; NEIGHBOR_OFFSETS defines which cells count as
## "adjacent" for auto-creating a WallEdge between two posts.

const CELL_SIZE: float = 2.0

const NEIGHBOR_OFFSETS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)
]

static func world_to_cell(world_pos: Vector3) -> Vector2i:
	return Vector2i(roundi(world_pos.x / CELL_SIZE), roundi(world_pos.z / CELL_SIZE))

static func cell_to_world(cell: Vector2i) -> Vector3:
	return Vector3(cell.x * CELL_SIZE, 0.0, cell.y * CELL_SIZE)
