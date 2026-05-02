extends SceneTree

const CellFunctionCatalog = preload("res://src/sim/catalog/cell_function_catalog.gd")
const EnergyConfig = preload("res://src/sim/energy/energy_config.gd")
const OrganismSnapshotBuilder = preload("res://src/runtime/organism_snapshot_builder.gd")
const SimulationService = preload("res://src/sim/simulation_service.gd")
const StarterBacteriumFactory = preload("res://src/sim/body/starter_bacterium_factory.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	_validate_end_to_end_energy(failures)
	_validate_docs(failures)
	_validate_source_boundaries(failures)
	_finish("Slice 2 integration validation", failures)


func _validate_end_to_end_energy(failures: Array[String]) -> void:
	var catalog = CellFunctionCatalog.default_catalog()
	var config = EnergyConfig.new()
	var service = SimulationService.new()
	get_root().add_child(service)
	var body = StarterBacteriumFactory.new().build(service, 1, 21)
	service.reset_energy(1, catalog, config)
	for _i in 3:
		service.tick_energy(1, catalog, config)
	var metrics = service.get_energy_metrics(1)
	metrics["low_energy_ratio"] = config.low_energy_ratio
	var snapshot = OrganismSnapshotBuilder.build(body, catalog, metrics)
	if snapshot.cell_count != 7:
		failures.append("Slice 2 should keep starter body at 7 cells.")
	if body.get_cell_count() != 7:
		failures.append("Energy tick must not grow the organism.")
	if int(metrics["tick_index"]) != 3:
		failures.append("Energy tick index should reach 3.")
	if not snapshot.energy_metrics.has("last_net"):
		failures.append("Snapshot should expose energy metrics read data.")
	if snapshot.organism_energy_ratio <= 0.5:
		failures.append("Energy ratio should increase after positive starter net.")


func _validate_docs(failures: Array[String]) -> void:
	var decisions = FileAccess.get_file_as_string("res://docs/DECISIONS.md")
	if not decisions.contains("ADR-007: Energy Tick Architecture"):
		failures.append("DECISIONS.md missing ADR-007.")
	if not decisions.contains("ADR-008: Slice 2 Tick Mechanism"):
		failures.append("DECISIONS.md missing ADR-008.")
	var findings = FileAccess.get_file_as_string("res://docs/FINDINGS.md")
	if not findings.contains("TimeService") or not findings.contains("SimulationService grows"):
		failures.append("FINDINGS.md missing Slice 2 future evaluation triggers.")


func _validate_source_boundaries(failures: Array[String]) -> void:
	var renderer_source = FileAccess.get_file_as_string("res://src/rendering/hex_organism_renderer.gd")
	for forbidden in ["SimulationService", "EnergySystem", "OrganismEnergyState"]:
		if renderer_source.contains(forbidden):
			failures.append("Renderer must not depend on %s." % forbidden)
	var snapshot_source = FileAccess.get_file_as_string("res://src/runtime/organism_snapshot_builder.gd")
	if snapshot_source.contains("get_body(") or snapshot_source.contains("tick_energy"):
		failures.append("SnapshotBuilder should not call SimulationService APIs.")


func _finish(label: String, failures: Array[String]) -> void:
	if failures.is_empty():
		print("%s: OK" % label)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
