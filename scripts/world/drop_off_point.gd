class_name DropOffPoint
extends Node3D

signal resource_deposited(resource_type: String, new_total: int)

var deposited: Dictionary = {}

func _ready() -> void:
	WorldRegistry.register_drop_off(self)

func _exit_tree() -> void:
	WorldRegistry.unregister_drop_off(self)

func deposit(resource_type: String) -> void:
	deposited[resource_type] = deposited.get(resource_type, 0) + 1
	resource_deposited.emit(resource_type, deposited[resource_type])
	print("Delivered %s (total: %d)" % [resource_type, deposited[resource_type]])
