class_name Post
extends StaticBody3D

var cell: Vector2i

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func setup(new_cell: Vector2i) -> void:
	cell = new_cell
	position = BuildGrid.cell_to_world(new_cell)

func _ready() -> void:
	WorldRegistry.register_post(cell, self)

func _exit_tree() -> void:
	WorldRegistry.unregister_post(cell)

func set_highlighted(value: bool) -> void:
	mesh_instance.material_overlay = HighlightUtil.get_material() if value else null
