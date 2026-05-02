class_name OrganismSnapshotBuilder
extends RefCounted

const CellBlock = preload("res://src/sim/body/cell_block.gd")
const CellFunctionCatalog = preload("res://src/sim/catalog/cell_function_catalog.gd")
const OrganismBody = preload("res://src/sim/body/organism_body.gd")
const OrganismRenderSnapshot = preload("res://src/runtime/organism_render_snapshot.gd")


static func build(body, catalog, energy_metrics: Dictionary = {}):
	var snapshot = OrganismRenderSnapshot.new(body.organism_id, body.seed)
	var keys = body.get_cell_keys()
	var boundary_outline_scale_by_function_id = _build_boundary_outline_scale_map(catalog)
	snapshot.energy_metrics = energy_metrics.duplicate(true)
	snapshot.organism_energy_ratio = clampf(float(energy_metrics.get("energy_ratio", 0.0)), 0.0, 1.0)
	var is_low_energy = snapshot.organism_energy_ratio <= float(energy_metrics.get("low_energy_ratio", 0.25)) and float(energy_metrics.get("max_energy", 0.0)) > 0.0

	for key in keys:
		var cell = body.get_cell_by_key(key)
		var definition = catalog.get_definition(cell.function_id) if catalog != null else null
		var base_color = definition.base_color if definition != null else Color.WHITE
		var accent_color = definition.accent_color if definition != null else Color.WHITE
		var accent_kind = definition.accent_kind if definition != null else "none"
		var energy_activity = _calculate_energy_activity(definition, snapshot.organism_energy_ratio)
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
			"is_boundary": body.is_boundary_cell(cell.coord),
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
