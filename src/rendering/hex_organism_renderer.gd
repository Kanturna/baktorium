class_name HexOrganismRenderer
extends Node2D

const HexCoord = preload("res://src/core/hex/hex_coord.gd")
const HexGridMath = preload("res://src/core/hex/hex_grid_math.gd")
const HexRenderConfig = preload("res://src/rendering/hex_render_config.gd")
const HexOutlineDrawer = preload("res://src/rendering/hex_outline_drawer.gd")
const HexDebugOverlay = preload("res://src/rendering/hex_debug_overlay.gd")
const OrganismRenderSnapshot = preload("res://src/runtime/organism_render_snapshot.gd")
const WallFlowRenderer = preload("res://src/rendering/wall_flow_renderer.gd")

var render_config
var snapshot
var elapsed_seconds: float = 0.0
var boundary_overlay: Node2D
var _sprite_nodes_by_key: Dictionary = {}


func _ready() -> void:
	boundary_overlay = Node2D.new()
	boundary_overlay.name = "AntialiasedBoundaryOverlay"
	add_child(boundary_overlay)
	_sync_boundary_overlay()


func _process(delta: float) -> void:
	elapsed_seconds += delta
	if render_config != null and render_config.flow_enabled:
		queue_redraw()


func set_snapshot(p_snapshot) -> void:
	snapshot = p_snapshot
	_sync_sprite_nodes()
	_sync_boundary_overlay()
	queue_redraw()


func set_render_config(p_config) -> void:
	render_config = p_config
	_sync_sprite_nodes()
	_sync_boundary_overlay()
	queue_redraw()


func _draw() -> void:
	if render_config == null:
		return
	draw_rect(Rect2(Vector2(-4000, -4000), Vector2(8000, 8000)), render_config.background_color, true)
	if snapshot == null:
		return

	if _is_beauty_mode():
		if render_config.boundary_glow_enabled or render_config.flow_enabled:
			for edge in snapshot.boundary_edges:
				_draw_boundary_edge(edge)
		return

	for cell_data in snapshot.cells:
		_draw_debug_cell(cell_data)

	for edge in snapshot.boundary_edges:
		_draw_boundary_edge(edge)

	if render_config.show_debug_overlay:
		for cell_data in snapshot.cells:
			var center = _coord_to_pixel(cell_data["coord"])
			HexDebugOverlay.draw_cell_label(self, center, cell_data, render_config)


func _draw_debug_cell(cell_data: Dictionary) -> void:
	var center = _coord_to_pixel(cell_data["coord"])
	var polygon = _translated_polygon(center)
	var color: Color = cell_data["base_color"]
	color = _apply_energy_tint(color, cell_data)
	color.a = render_config.cell_fill_alpha
	draw_colored_polygon(polygon, color)

	var outline_color: Color = cell_data["accent_color"]
	outline_color.a = 0.38
	HexOutlineDrawer.draw_polygon_outline(self, polygon, outline_color, render_config.inner_outline_width)

	_draw_debug_accent(center, cell_data)


func _draw_debug_accent(center: Vector2, cell_data: Dictionary) -> void:
	var energy_activity = clampf(float(cell_data.get("energy_activity", 0.0)), 0.0, 1.0)
	match cell_data.get("accent_kind", "none"):
		"glow_disc":
			var glow_color: Color = cell_data["accent_color"]
			glow_color.a = clampf(render_config.glow_strength + energy_activity * 0.28, 0.0, 0.92)
			draw_circle(center, render_config.hex_radius * (0.40 + energy_activity * 0.10), glow_color)
			draw_circle(center, render_config.hex_radius * 0.18, cell_data["accent_color"])
		"surface_dot":
			var accent: Color = cell_data["accent_color"]
			accent.a = clampf(0.45 + energy_activity * 0.35, 0.0, 0.90)
			draw_circle(center + Vector2(0, -render_config.hex_radius * 0.12), render_config.hex_radius * (0.14 + energy_activity * 0.04), accent)
		"ring_arc":
			var accent_repro: Color = cell_data["accent_color"]
			accent_repro.a = 0.55
			draw_arc(center, render_config.hex_radius * 0.24, 0.0, TAU, 24, accent_repro, 3.0, true)


func _apply_energy_tint(base_color: Color, cell_data: Dictionary) -> Color:
	var energy_ratio = clampf(float(cell_data.get("energy_tint_strength", 0.0)), 0.0, 1.0)
	var energy_activity = clampf(float(cell_data.get("energy_activity", 0.0)), 0.0, 1.0)
	if cell_data.get("energy_low", false):
		return base_color.lerp(Color(1.0, 0.24, 0.18, 1.0), 0.18)
	var tint_strength = clampf(energy_ratio * 0.08 + energy_activity * 0.12, 0.0, 0.24)
	return base_color.lerp(Color(1.0, 0.92, 0.46, 1.0), tint_strength)


func _draw_boundary_edge(edge: Dictionary) -> void:
	var segment = _edge_to_segment(edge)
	var coord = segment["coord"]
	var direction: int = segment["direction"]
	var from_point: Vector2 = segment["from"]
	var to_point: Vector2 = segment["to"]
	var width: float = segment["width"]
	var color: Color = segment["color"]
	if not HexOutlineDrawer.plugin_available():
		HexOutlineDrawer.draw_edge(self, from_point, to_point, color, width)
	if render_config.flow_enabled:
		WallFlowRenderer.draw_flow_edge(self, from_point, to_point, color, width, elapsed_seconds, coord.q * 131 + coord.r * 71 + direction, render_config)


func _coord_to_pixel(coord) -> Vector2:
	return HexGridMath.hex_to_pixel(coord, render_config.hex_radius, render_config.pointy_top)


func _translated_polygon(center: Vector2) -> PackedVector2Array:
	var base = HexGridMath.polygon_points(render_config.hex_radius, render_config.pointy_top)
	var translated = PackedVector2Array()
	for point in base:
		translated.append(point + center)
	return translated


func _sync_sprite_nodes() -> void:
	if snapshot == null or render_config == null:
		_set_sprite_nodes_visible(false)
		return

	if not _is_beauty_mode():
		_set_sprite_nodes_visible(false)
		return

	var active_keys: Dictionary = {}
	for cell_data in snapshot.cells:
		var key = _cell_key(cell_data)
		active_keys[key] = true
		var node = _ensure_sprite_node(key, cell_data)
		_configure_sprite_node(node, cell_data)

	for key in _sprite_nodes_by_key.keys():
		if not active_keys.has(key):
			var stale = _sprite_nodes_by_key[key]
			if is_instance_valid(stale):
				stale.queue_free()
			_sprite_nodes_by_key.erase(key)


func _ensure_sprite_node(key: String, cell_data: Dictionary) -> Node2D:
	var frames = cell_data.get("sprite_frames", null)
	var wants_animated = frames != null
	var node = _sprite_nodes_by_key.get(key)
	if node != null and is_instance_valid(node):
		if wants_animated and node is AnimatedSprite2D:
			return node
		if not wants_animated and node is Sprite2D:
			return node
		node.queue_free()

	node = AnimatedSprite2D.new() if wants_animated else Sprite2D.new()
	node.name = "CellSprite_%s" % key.replace(",", "_")
	add_child(node)
	_sprite_nodes_by_key[key] = node
	return node


func _configure_sprite_node(node: Node2D, cell_data: Dictionary) -> void:
	node.visible = _is_beauty_mode()
	node.position = _coord_to_pixel(cell_data["coord"])
	node.scale = Vector2.ONE * _calculate_sprite_scale(cell_data)
	node.modulate = _calculate_sprite_modulate(cell_data)
	node.z_index = 2

	if node is AnimatedSprite2D:
		var animated = node as AnimatedSprite2D
		animated.sprite_frames = cell_data.get("sprite_frames", null)
		animated.animation = &"default"
		animated.speed_scale = _calculate_animation_speed(cell_data)
		if not animated.is_playing():
			animated.play("default")
	elif node is Sprite2D:
		var sprite = node as Sprite2D
		sprite.texture = cell_data.get("sprite_texture", null)


func _set_sprite_nodes_visible(is_visible: bool) -> void:
	for node in _sprite_nodes_by_key.values():
		if is_instance_valid(node):
			node.visible = is_visible


func _calculate_sprite_scale(cell_data: Dictionary) -> float:
	var texture = _selected_texture(cell_data)
	if texture == null:
		return 1.0
	var source_size = maxf(float(texture.get_width()), float(texture.get_height()))
	if source_size <= 0.0:
		return 1.0
	var target_diameter = render_config.hex_radius * 2.0 * render_config.sprite_diameter_scale
	return target_diameter / source_size


func _selected_texture(cell_data: Dictionary):
	var frames = cell_data.get("sprite_frames", null)
	if frames != null and frames.has_animation(&"default") and frames.get_frame_count(&"default") > 0:
		return frames.get_frame_texture(&"default", 0)
	return cell_data.get("sprite_texture", null)


func _calculate_animation_speed(cell_data: Dictionary) -> float:
	var modulator = clampf(float(cell_data.get("animation_modulator", 0.5)), 0.0, 1.0)
	var strength = clampf(float(cell_data.get("animation_modulation_strength", 0.0)), 0.0, 1.0)
	return clampf(1.0 + strength * (modulator - 0.5) * 2.0, 0.25, 2.0)


func _calculate_sprite_modulate(cell_data: Dictionary) -> Color:
	var color = Color.WHITE
	var energy_ratio = clampf(float(cell_data.get("energy_tint_strength", 0.0)), 0.0, 1.0)
	var energy_activity = clampf(float(cell_data.get("energy_activity", 0.0)), 0.0, 1.0)
	if cell_data.get("energy_low", false):
		return color.lerp(Color(1.0, 0.35, 0.25, 1.0), 0.16)
	var boost = clampf(energy_ratio * 0.05 + energy_activity * 0.08, 0.0, 0.16)
	return color.lerp(Color(1.0, 0.96, 0.74, 1.0), boost)


func _is_beauty_mode() -> bool:
	return render_config != null and render_config.render_mode == "beauty"


func _cell_key(cell_data: Dictionary) -> String:
	return "%d,%d" % [int(cell_data["q"]), int(cell_data["r"])]


func _sync_boundary_overlay() -> void:
	if boundary_overlay == null:
		return
	if snapshot == null or render_config == null:
		HexOutlineDrawer.sync_boundary_overlay(boundary_overlay, [])
		return
	var should_show_boundary = (not _is_beauty_mode()) or render_config.boundary_glow_enabled
	boundary_overlay.visible = should_show_boundary
	HexOutlineDrawer.sync_boundary_overlay(boundary_overlay, _boundary_segments() if should_show_boundary else [])


func _boundary_segments() -> Array:
	var segments: Array = []
	if snapshot == null:
		return segments
	for edge in snapshot.boundary_edges:
		segments.append(_edge_to_segment(edge))
	return segments


func _edge_to_segment(edge: Dictionary) -> Dictionary:
	var coord = edge["coord"]
	var direction: int = edge["direction"]
	var center = _coord_to_pixel(coord)
	var polygon = _translated_polygon(center)
	var width = render_config.boundary_outline_width * float(edge.get("boundary_outline_scale", 1.0))
	return {
		"from": polygon[direction],
		"to": polygon[(direction + 1) % polygon.size()],
		"width": width,
		"color": Color(0.78, 0.92, 1.0, render_config.boundary_alpha),
		"coord": coord,
		"direction": direction,
	}
