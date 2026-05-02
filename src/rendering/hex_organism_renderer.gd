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
	_sync_boundary_overlay()
	queue_redraw()


func set_render_config(p_config) -> void:
	render_config = p_config
	_sync_boundary_overlay()
	queue_redraw()


func _draw() -> void:
	if render_config == null:
		return
	draw_rect(Rect2(Vector2(-2000, -2000), Vector2(4000, 4000)), render_config.background_color, true)
	if snapshot == null:
		return

	for cell_data in snapshot.cells:
		_draw_cell(cell_data)

	for edge in snapshot.boundary_edges:
		_draw_boundary_edge(edge)

	if render_config.show_debug_overlay:
		for cell_data in snapshot.cells:
			var center = _coord_to_pixel(cell_data["coord"])
			HexDebugOverlay.draw_cell_label(self, center, cell_data, render_config)


func _draw_cell(cell_data: Dictionary) -> void:
	var center = _coord_to_pixel(cell_data["coord"])
	var polygon = _translated_polygon(center)
	var color: Color = cell_data["base_color"]
	color.a = render_config.cell_fill_alpha
	draw_colored_polygon(polygon, color)

	var outline_color: Color = cell_data["accent_color"]
	outline_color.a = 0.38
	HexOutlineDrawer.draw_polygon_outline(self, polygon, outline_color, render_config.inner_outline_width)

	if cell_data["function_id"] == &"energy_core":
		var glow_color: Color = cell_data["accent_color"]
		glow_color.a = render_config.glow_strength
		draw_circle(center, render_config.hex_radius * 0.44, glow_color)
		draw_circle(center, render_config.hex_radius * 0.18, cell_data["accent_color"])
	elif cell_data["function_id"] == &"photosynthesis":
		var accent: Color = cell_data["accent_color"]
		accent.a = 0.65
		draw_circle(center + Vector2(0, -render_config.hex_radius * 0.12), render_config.hex_radius * 0.16, accent)
	elif cell_data["function_id"] == &"reproduction":
		var accent_repro: Color = cell_data["accent_color"]
		accent_repro.a = 0.55
		draw_arc(center, render_config.hex_radius * 0.24, 0.0, TAU, 24, accent_repro, 3.0, true)


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


func _sync_boundary_overlay() -> void:
	if boundary_overlay == null or snapshot == null or render_config == null:
		return
	HexOutlineDrawer.sync_boundary_overlay(boundary_overlay, _boundary_segments())


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
	var width = render_config.wall_outline_width if edge["function_id"] == &"wall" else render_config.boundary_outline_width
	return {
		"from": polygon[direction],
		"to": polygon[(direction + 1) % polygon.size()],
		"width": width,
		"color": Color(0.78, 0.92, 1.0, render_config.boundary_alpha),
		"coord": coord,
		"direction": direction,
	}
