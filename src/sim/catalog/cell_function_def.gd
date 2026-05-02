class_name CellFunctionDef
extends Resource

@export var id: StringName = &""
@export var display_name: String = ""
@export var base_color: Color = Color.WHITE
@export var accent_color: Color = Color.WHITE
@export_enum("none", "glow_disc", "surface_dot", "ring_arc") var accent_kind: String = "none"
@export var energy_production: float = 0.0
@export var energy_capacity: float = 0.0
@export var maintenance_cost: float = 0.0
@export var growth_cost: float = 0.0
@export var protection_value: float = 0.0
@export var requires_surface: bool = false
@export_range(0.5, 2.0, 0.05) var boundary_outline_scale: float = 1.0
@export var visual_weight: float = 1.0
@export var outer_sprite_texture: Texture2D = null
@export var inner_sprite_texture: Texture2D = null
@export var outer_sprite_frames: SpriteFrames = null
@export var inner_sprite_frames: SpriteFrames = null
@export_range(1.0, 24.0, 0.5) var animation_base_fps: float = 8.0
@export_range(0.0, 1.0, 0.05) var animation_modulation_strength: float = 0.5
