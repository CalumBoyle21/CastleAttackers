extends Control

@onready var list_container: VBoxContainer = %ListContainer
@onready var craft_list_container: VBoxContainer = %CraftListContainer

var _bound_drop_off: DropOffPoint = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

func is_open() -> bool:
	return visible

func open_for(drop_off: DropOffPoint) -> void:
	_unbind()
	_bound_drop_off = drop_off
	_bound_drop_off.inventory_changed.connect(_on_inventory_changed)
	_refresh()
	show()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close() -> void:
	_unbind()
	hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if is_open() and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

func _unbind() -> void:
	if _bound_drop_off and _bound_drop_off.inventory_changed.is_connected(_on_inventory_changed):
		_bound_drop_off.inventory_changed.disconnect(_on_inventory_changed)
	_bound_drop_off = null

func _on_inventory_changed() -> void:
	_refresh()

func _refresh() -> void:
	_refresh_inventory()
	_refresh_crafting()

func _refresh_inventory() -> void:
	for child in list_container.get_children():
		child.queue_free()

	if _bound_drop_off == null or _bound_drop_off.deposited.is_empty():
		var empty_label := Label.new()
		empty_label.text = "Empty"
		list_container.add_child(empty_label)
		return

	for resource_type in _bound_drop_off.deposited:
		var row := Label.new()
		row.text = "%s: %d" % [resource_type.capitalize(), _bound_drop_off.deposited[resource_type]]
		list_container.add_child(row)

func _refresh_crafting() -> void:
	for child in craft_list_container.get_children():
		child.queue_free()

	if _bound_drop_off == null:
		return

	for recipe in CraftingRecipes.ALL:
		var row := HBoxContainer.new()

		var label := Label.new()
		label.text = "%s (%s)" % [recipe["name"], _format_costs(recipe["costs"])]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)

		var button := Button.new()
		button.text = "Craft"
		button.disabled = not _bound_drop_off.can_afford(recipe["costs"])
		button.pressed.connect(_on_craft_pressed.bind(recipe))
		row.add_child(button)

		craft_list_container.add_child(row)

func _format_costs(costs: Dictionary) -> String:
	var parts: Array[String] = []
	for resource_type in costs:
		parts.append("%d %s" % [costs[resource_type], resource_type.capitalize()])
	return ", ".join(parts)

func _on_craft_pressed(recipe: Dictionary) -> void:
	_bound_drop_off.craft(recipe)