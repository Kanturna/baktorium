class_name CellFunctionDef
extends Resource

@export var id: StringName = &""
@export var display_name: String = ""
@export var base_color: Color = Color.WHITE
@export var accent_color: Color = Color.WHITE
@export_enum("none", "glow_disc", "surface_dot", "ring_arc") var accent_kind: String = "none"
@export var energy_production: float = 0.0
@export var maintenance_cost: float = 0.0
@export var growth_cost: float = 0.0
@export var protection_value: float = 0.0
@export var requires_surface: bool = false
@export_range(0.5, 2.0, 0.05) var boundary_outline_scale: float = 1.0
@export var visual_weight: float = 1.0
