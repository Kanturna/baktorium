class_name OrganismSnapshotBuilder
extends RefCounted

const CellBlock = preload("res://src/sim/body/cell_block.gd")
const CellFunctionCatalog = preload("res://src/sim/catalog/cell_function_catalog.gd")
const OrganismBody = preload("res://src/sim/body/organism_body.gd")
const OrganismRenderSnapshot = preload("res://src/runtime/organism_render_snapshot.gd")


static func build(body, catalog, energy_metrics: Dictionary = {}, render_hints: Dictionary = {}):
	var snapshot = OrganismRenderSnapshot.new(body.organism_id, body.seed)
	var keys = body.get_cell_keys()
	var boundary_outline_scale_by_function_id = _build_boundary_outline_scale_map(catalog)
	snapshot.energy_metrics = energy_metrics.duplicate(true)
	snapshot.organism_energy_ratio = clampf(float(energy_metrics.get("energy_ratio", 0.0)), 0.0, 1.0)
	var low_energy_ratio = float(render_hints.get("low_energy_ratio", 0.25))
	var is_low_energy = snapshot.organism_energy_ratio <= low_energy_ratio and float(energy_metrics.get("max_energy", 0.0)) > 0.0

	for key in keys:
		var cell = body.get_cell_by_key(key)
		var definition = catalog.get_definition(cell.function_id) if catalog != null else null
		var base_color = definition.base_color if definition != null else Color.WHITE
		var accent_color = definition.accent_color if definition != null else Color.WHITE
		var accent_kind = definition.accent_kind if definition != null else "none"
		var energy_activity = _calculate_energy_activity(definition, snapshot.organism_energy_ratio)
		var is_boundary = body.is_boundary_cell(cell.coord)
		var sprite_recipe = _build_sprite_recipe(definition, is_boundary, accent_kind, snapshot.organism_energy_ratio, energy_activity)
		snapshot.cells.append({
			"coord": cell.coord.duplicate_coord(),
			"q": cell.coord.q,
			"r": cell.coord.r,
			"function_id": cell.function_id,
			"base_color": base_color,
			"accent_color": accent_color,
			"accent_kind": accent_kind,
			"energy_tint_strength": snapshot.organism_energy_ratio,
			"energy_activity": energy_activity,
			"energy_low": is_low_energy,
			"visual_seed": cell.visual_seed,
			"is_boundary": is_boundary,
			"outer_sprite_texture": sprite_recipe["outer_sprite_texture"],
			"inner_sprite_texture": sprite_recipe["inner_sprite_texture"],
			"outer_sprite_frames": sprite_recipe["outer_sprite_frames"],
			"inner_sprite_frames": sprite_recipe["inner_sprite_frames"],
			"sprite_texture": sprite_recipe["sprite_texture"],
			"sprite_frames": sprite_recipe["sprite_frames"],
			"animation_base_fps": sprite_recipe["animation_base_fps"],
			"animation_modulation_strength": sprite_recipe["animation_modulation_strength"],
			"animation_modulator": sprite_recipe["animation_modulator"],
		})

	for edge in body.get_boundary_edges():
		var edge_copy = edge.duplicate(true)
		edge_copy["boundary_outline_scale"] = boundary_outline_scale_by_function_id.get(edge["function_id"], 1.0)
		snapshot.boundary_edges.append(edge_copy)
	snapshot.cell_count = snapshot.cells.size()
	return snapshot


static func _build_boundary_outline_scale_map(catalog) -> Dictionary:
	var result: Dictionary = {}
	if catalog == null:
		return result
	for function_id in catalog.ids():
		var definition = catalog.get_definition(function_id)
		if definition != null:
			result[function_id] = definition.boundary_outline_scale
	return result


static func _calculate_energy_activity(definition, energy_ratio: float) -> float:
	if definition == null:
		return 0.0
	if definition.energy_capacity > 0.0:
		return clampf(energy_ratio, 0.0, 1.0)
	if definition.energy_production > 0.0:
		return clampf(definition.energy_production / 2.0, 0.0, 1.0)
	if definition.maintenance_cost > 0.0:
		return clampf(energy_ratio * 0.12, 0.0, 0.25)
	return 0.0


static func _build_sprite_recipe(definition, is_boundary: bool, accent_kind: String, energy_ratio: float, energy_activity: float) -> Dictionary:
	var recipe = {
		"outer_sprite_texture": null,
		"inner_sprite_texture": null,
		"outer_sprite_frames": null,
		"inner_sprite_frames": null,
		"sprite_texture": null,
		"sprite_frames": null,
		"animation_base_fps": 8.0,
		"animation_modulation_strength": 0.0,
		"animation_modulator": 0.5,
	}
	if definition == null:
		return recipe

	recipe["outer_sprite_texture"] = definition.outer_sprite_texture
	recipe["inner_sprite_texture"] = definition.inner_sprite_texture
	recipe["outer_sprite_frames"] = definition.outer_sprite_frames
	recipe["inner_sprite_frames"] = definition.inner_sprite_frames
	recipe["animation_base_fps"] = definition.animation_base_fps
	recipe["animation_modulation_strength"] = definition.animation_modulation_strength
	recipe["animation_modulator"] = _calculate_animation_modulator(accent_kind, energy_ratio, energy_activity)

	if is_boundary or definition.inner_sprite_texture == null:
		recipe["sprite_texture"] = definition.outer_sprite_texture
	else:
		recipe["sprite_texture"] = definition.inner_sprite_texture

	if is_boundary or definition.inner_sprite_frames == null:
		recipe["sprite_frames"] = definition.outer_sprite_frames
	else:
		recipe["sprite_frames"] = definition.inner_sprite_frames

	return recipe


static func _calculate_animation_modulator(accent_kind: String, energy_ratio: float, energy_activity: float) -> float:
	match accent_kind:
		"glow_disc":
			return clampf(energy_ratio, 0.0, 1.0)
		"surface_dot":
			return clampf(energy_activity, 0.0, 1.0)
		"ring_arc":
			return clampf(0.45 + energy_ratio * 0.25, 0.0, 1.0)
		_:
			return clampf(0.35 + energy_activity * 0.30, 0.0, 1.0)
