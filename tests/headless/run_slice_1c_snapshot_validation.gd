extends SceneTree

const CellFunctionCatalog = preload("res://src/sim/catalog/cell_function_catalog.gd")
const OrganismRenderSnapshot = preload("res://src/runtime/organism_render_snapshot.gd")
const OrganismSnapshotBuilder = preload("res://src/runtime/organism_snapshot_builder.gd")
const SimulationService = preload("res://src/sim/simulation_service.gd")
const StarterBacteriumFactory = preload("res://src/sim/body/starter_bacterium_factory.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	var catalog = CellFunctionCatalog.default_catalog()
	var service = SimulationService.new()
	get_root().add_child(service)
	var body = StarterBacteriumFactory.new().build(service, 1, 11)
	var snapshot = OrganismSnapshotBuilder.build(body, catalog)

	_validate_snapshot(snapshot, failures)
	_validate_renderer_boundary(failures)
	_finish("Slice 1C snapshot validation", failures)


func _validate_snapshot(snapshot, failures: Array[String]) -> void:
	if snapshot.cell_count != 7:
		failures.append("Snapshot should contain 7 cells, found %d." % snapshot.cell_count)
	if snapshot.boundary_edges.is_empty():
		failures.append("Snapshot should contain boundary edges.")
	for cell_data in snapshot.cells:
		if not cell_data.has("coord") or not cell_data.has("function_id") or not cell_data.has("base_color"):
			failures.append("Snapshot cell data missing required render fields.")
		if cell_data.has("cell_ref") or cell_data.has("body"):
			failures.append("Snapshot must not expose mutable body/cell references.")


func _validate_renderer_boundary(failures: Array[String]) -> void:
	var renderer_source = FileAccess.get_file_as_string("res://src/rendering/hex_organism_renderer.gd")
	if renderer_source.contains("OrganismBody") or renderer_source.contains("get_body("):
		failures.append("Renderer must not depend on OrganismBody.")
	var snapshot_source = FileAccess.get_file_as_string("res://src/runtime/organism_render_snapshot.gd")
	if snapshot_source.is_empty():
		failures.append("OrganismRenderSnapshot must live in src/runtime/.")


func _finish(label: String, failures: Array[String]) -> void:
	if failures.is_empty():
		print("%s: OK" % label)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
