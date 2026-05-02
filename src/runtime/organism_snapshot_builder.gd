class_name OrganismSnapshotBuilder
extends RefCounted

const CellBlock = preload("res://src/sim/body/cell_block.gd")
const CellFunctionCatalog = preload("res://src/sim/catalog/cell_function_catalog.gd")
const OrganismBody = preload("res://src/sim/body/organism_body.gd")
const OrganismRenderSnapshot = preload("res://src/runtime/organism_render_snapshot.gd")


static func build(body, catalog):
	var snapshot = OrganismRenderSnapshot.new(body.organism_id, body.seed)
	var keys = body.cells_by_key.keys()
	keys.sort()

	for key in keys:
		var cell = body.cells_by_key[key]
		var definition = catalog.get_definition(cell.function_id) if catalog != null else null
		var base_color = definition.base_color if definition != null else Color.WHITE
		var accent_color = definition.accent_color if definition != null else Color.WHITE
		snapshot.cells.append({
			"coord": cell.coord.duplicate_coord(),
			"q": cell.coord.q,
			"r": cell.coord.r,
			"function_id": cell.function_id,
			"base_color": base_color,
			"accent_color": accent_color,
			"visual_seed": cell.visual_seed,
			"is_boundary": body.is_boundary_cell(cell.coord),
		})

	snapshot.boundary_edges = body.get_boundary_edges()
	snapshot.cell_count = snapshot.cells.size()
	return snapshot
