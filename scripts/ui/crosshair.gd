extends Control

## Small reticle at screen center showing where the interact raycast
## aims. Brightens/grows when something interactable is under it.

const RADIUS: float = 5.0
const RING_WIDTH: float = 2.0
const COLOR_DEFAULT: Color = Color(1, 1, 1, 0.85)
const COLOR_ACTIVE: Color = Color(0.95, 0.85, 0.2, 0.95)

var is_active: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)

func set_active(value: bool) -> void:
	if is_active == value:
		return
	is_active = value
	queue_redraw()

func _draw() -> void:
	var center: Vector2 = size / 2.0
	var color: Color = COLOR_ACTIVE if is_active else COLOR_DEFAULT
	var radius: float = RADIUS * 1.4 if is_active else RADIUS
	draw_arc(center, radius, 0, TAU, 32, color, RING_WIDTH, true)
