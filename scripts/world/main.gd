extends Node3D

@export var villager_scene: PackedScene
@export var villager_count: int = 1
@export var spawn_radius: float = 5.0

@onready var villagers_root: Node3D = $Villagers

func _ready() -> void:
	_spawn_villagers()

func _spawn_villagers() -> void:
	if villager_scene == null:
		push_warning("Error with spawn, skipping.")
		return
	for i in villager_count:
		var villager: Node3D = villager_scene.instantiate()
		var offset := Vector3(
			randf_range(-spawn_radius, spawn_radius),
			0.1,
			randf_range(-spawn_radius, spawn_radius)
		)
		villager.position = offset
		villagers_root.add_child(villager)
