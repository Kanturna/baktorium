class_name HexRenderConfig
extends Resource

@export_range(12.0, 96.0, 1.0) var hex_radius: float = 42.0
@export var pointy_top: bool = true
@export_enum("beauty", "debug") var render_mode: String = "beauty"
@export_range(1.0, 3.0, 0.05) var sprite_diameter_scale: float = 2.2
@export_range(0.0, 12.0, 0.5) var inner_outline_width: float = 2.0
@export_range(0.0, 16.0, 0.5) var boundary_outline_width: float = 5.0
@export_range(0.0, 20.0, 0.5) var wall_outline_width: float = 7.0
@export_range(0.0, 1.0, 0.01) var cell_fill_alpha: float = 0.94
@export_range(0.0, 1.0, 0.01) var boundary_alpha: float = 0.90
@export_range(0.0, 1.0, 0.01) var glow_strength: float = 0.45
@export var flow_enabled: bool = false
@export var boundary_glow_enabled: bool = false
@export_range(0.0, 8.0, 0.05) var flow_speed: float = 1.25
@export_range(0.0, 8.0, 0.05) var flow_amplitude: float = 2.0
@export var show_debug_overlay: bool = true
@export var show_coordinates: bool = true
@export var show_function_ids: bool = true
@export var background_color: Color = Color(0.055, 0.060, 0.075, 1.0)
@export var label_color: Color = Color(0.92, 0.95, 1.0, 0.92)
