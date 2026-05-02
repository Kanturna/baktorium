class_name HexOutlineDrawer
extends RefCounted


static func plugin_available() -> bool:
	return FileAccess.file_exists("res://addons/antialiased_line2d/antialiased_line2d.gd")


static func sync_boundary_overlay(container: Node, segments: Array) -> void:
	for child in container.get_children():
		child.queue_free()

	if not plugin_available():
		return

	var line_script = load("res://addons/antialiased_line2d/antialiased_line2d.gd")
	for segment in segments:
		var line = line_script.new()
		line.width = segment["width"]
		line.default_color = segment["color"]
		line.points = PackedVector2Array([segment["from"], segment["to"]])
		container.add_child(line)


static func draw_edge(canvas: CanvasItem, from_point: Vector2, to_point: Vector2, color: Color, width: float) -> void:
	canvas.draw_line(from_point, to_point, color, width, true)


static func draw_polygon_outline(canvas: CanvasItem, points: PackedVector2Array, color: Color, width: float) -> void:
	for index in points.size():
		var from_point = points[index]
		var to_point = points[(index + 1) % points.size()]
		draw_edge(canvas, from_point, to_point, color, width)
