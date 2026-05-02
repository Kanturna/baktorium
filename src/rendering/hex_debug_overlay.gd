class_name HexDebugOverlay
extends RefCounted

const HexRenderConfig = preload("res://src/rendering/hex_render_config.gd")


static func draw_cell_label(canvas: CanvasItem, position: Vector2, cell_data: Dictionary, config) -> void:
	if config == null or not config.show_debug_overlay:
		return

	var lines: Array[String] = []
	if config.show_coordinates:
		lines.append("%d,%d" % [cell_data["q"], cell_data["r"]])
	if config.show_function_ids:
		lines.append(String(cell_data["function_id"]))
	if lines.is_empty():
		return

	var font = ThemeDB.fallback_font
	if font == null:
		return

	var text = "\n".join(lines)
	var font_size = 11
	var size = font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1.0, font_size)
	canvas.draw_multiline_string(
		font,
		position - Vector2(size.x * 0.5, size.y * 0.5),
		text,
		HORIZONTAL_ALIGNMENT_CENTER,
		-1.0,
		font_size,
		config.label_color
	)
