class_name WallFlowRenderer
extends RefCounted

const HexRenderConfig = preload("res://src/rendering/hex_render_config.gd")


static func draw_flow_edge(canvas: CanvasItem, from_point: Vector2, to_point: Vector2, color: Color, width: float, time_seconds: float, visual_seed: int, config) -> void:
	if config == null or not config.flow_enabled:
		return

	var phase = time_seconds * config.flow_speed + float(visual_seed % 31) * 0.19
	var pulse = 0.5 + 0.5 * sin(phase)
	var flow_color = color.lightened(0.25)
	flow_color.a *= 0.35 + pulse * 0.35
	var flow_width = max(1.0, width + pulse * config.flow_amplitude)
	canvas.draw_line(from_point, to_point, flow_color, flow_width, true)
