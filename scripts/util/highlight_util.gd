class_name HighlightUtil

static var _material: StandardMaterial3D = null

static func get_material() -> StandardMaterial3D:
	if _material == null:
		_material = StandardMaterial3D.new()
		_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_material.albedo_color = Color(1, 1, 1, 0.35)
		_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return _material
