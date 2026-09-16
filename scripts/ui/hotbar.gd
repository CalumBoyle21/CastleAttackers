extends Control

## Minecraft-style hotbar. Slots are a fixed mapping (index -> resource
## type), not dynamically derived from inventory contents — that keeps
## selection stable even as items are gained/spent (a Dictionary's key
## order isn't something a player should have to track). Counts are
## read live from the nearest DropOffPoint, same "home" every other
## interaction already uses. Add a new entry to SLOT_ITEMS to add a
## new hotbar slot; add it to PLACEABLE_TYPES if selecting it should
## drive BuildController's placement-ghost mode.

const SLOT_ITEMS: Array[String] = ["wood", "post", "board", "", "", "", "", "", ""]
const PLACEABLE_TYPES: Array[String] = ["post"]

@onready var slots_container: HBoxContainer = %SlotsContainer
@onready var player: Node3D = get_tree().current_scene.get_node("Player")

var selected_index: int = -1
var _bound_drop_off: DropOffPoint = null
var _slot_panels: Array[PanelContainer] = []
var _slot_labels: Array[Label] = []

var _normal_style: StyleBoxFlat
var _selected_style: StyleBoxFlat

func _ready() -> void:
	_build_styles()
	_build_slots()
	_refresh()

func _build_styles() -> void:
	_normal_style = StyleBoxFlat.new()
	_normal_style.bg_color = Color(0.05, 0.05, 0.05, 0.75)
	_normal_style.border_color = Color(0.4, 0.4, 0.4, 1)
	_normal_style.set_border_width_all(2)
	_normal_style.set_corner_radius_all(4)

	_selected_style = StyleBoxFlat.new()
	_selected_style.bg_color = Color(0.1, 0.1, 0.05, 0.85)
	_selected_style.border_color = Color(1.0, 0.85, 0.2, 1)
	_selected_style.set_border_width_all(3)
	_selected_style.set_corner_radius_all(4)

func _build_slots() -> void:
	for i in SLOT_ITEMS.size():
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(56, 56)
		panel.add_theme_stylebox_override("panel", _normal_style)

		var label := Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		panel.add_child(label)

		slots_container.add_child(panel)
		_slot_panels.append(panel)
		_slot_labels.append(label)

func _physics_process(_delta: float) -> void:
	var nearest := WorldRegistry.get_nearest_drop_off(player.global_position)
	if nearest != _bound_drop_off:
		_rebind(nearest)

func _rebind(drop_off: DropOffPoint) -> void:
	if _bound_drop_off and _bound_drop_off.inventory_changed.is_connected(_on_inventory_changed):
		_bound_drop_off.inventory_changed.disconnect(_on_inventory_changed)
	_bound_drop_off = drop_off
	if _bound_drop_off:
		_bound_drop_off.inventory_changed.connect(_on_inventory_changed)
	_refresh()

func _on_inventory_changed() -> void:
	_refresh()

func _refresh() -> void:
	for i in SLOT_ITEMS.size():
		var item_type: String = SLOT_ITEMS[i]
		if item_type == "":
			_slot_labels[i].text = ""
		else:
			var count: int = _bound_drop_off.deposited.get(item_type, 0) if _bound_drop_off else 0
			_slot_labels[i].text = "%s\n%d" % [item_type.capitalize(), count]
	_update_slot_visuals()

func _update_slot_visuals() -> void:
	for i in _slot_panels.size():
		_slot_panels[i].add_theme_stylebox_override(
			"panel", _selected_style if i == selected_index else _normal_style
		)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event: InputEventKey = event
		if key_event.keycode >= KEY_1 and key_event.keycode <= KEY_9:
			select_slot(key_event.keycode - KEY_1)

func select_slot(index: int) -> void:
	if index < 0 or index >= SLOT_ITEMS.size():
		return
	selected_index = index
	_update_slot_visuals()

## What the currently selected slot holds, "" if none/empty.
func get_selected_type() -> String:
	if selected_index < 0 or selected_index >= SLOT_ITEMS.size():
		return ""
	return SLOT_ITEMS[selected_index]

func is_selected_placeable() -> bool:
	return get_selected_type() in PLACEABLE_TYPES
