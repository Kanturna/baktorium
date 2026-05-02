extends SceneTree

const CellFunctionCatalog = preload("res://src/sim/catalog/cell_function_catalog.gd")
const EnergyConfig = preload("res://src/sim/energy/energy_config.gd")
const OrganismSnapshotBuilder = preload("res://src/runtime/organism_snapshot_builder.gd")
const SimulationService = preload("res://src/sim/simulation_service.gd")
const StarterBacteriumFactory = preload("res://src/sim/body/starter_bacterium_factory.gd")

const EPS := 0.001


func _initialize() -> void:
	var failures: Array[String] = []
	var catalog = CellFunctionCatalog.default_catalog()
	var config = EnergyConfig.new()
	var service = SimulationService.new()
	get_root().add_child(service)
	var body = StarterBacteriumFactory.new().build(service, 1, 13)
	service.reset_energy(1, catalog, config)
	service.tick_energy(1, catalog, config)

	var metrics = service.get_energy_metrics(1)
	var snapshot = OrganismSnapshotBuilder.build(body, catalog, metrics, {"low_energy_ratio": config.low_energy_ratio})

	_validate_snapshot_energy(snapshot, failures)
	_validate_cell_energy_recipe(snapshot, failures)
	_validate_renderer_boundary(failures)
	_validate_lab_contract(failures)
	_finish("Slice 2B energy snapshot validation", failures)


func _validate_snapshot_energy(snapshot, failures: Array[String]) -> void:
	if snapshot.energy_metrics.is_empty():
		failures.append("Snapshot should contain copied energy metrics.")
	_expect_close(snapshot.organism_energy_ratio, 17.6 / 30.0, "snapshot energy ratio", failures)
	if snapshot.energy_metrics["current_energy"] != 17.6:
		failures.append("Snapshot energy metrics should include current energy.")
	if snapshot.energy_metrics.has("low_energy_ratio"):
		failures.append("Snapshot energy metrics must not carry render thresholds.")
	snapshot.energy_metrics["current_energy"] = 999.0
	if snapshot.energy_metrics["current_energy"] != 999.0:
		failures.append("Snapshot energy metrics should be local read data.")


func _validate_cell_energy_recipe(snapshot, failures: Array[String]) -> void:
	var core_activity := -1.0
	var photo_activity := -1.0
	var wall_activity := 2.0
	for cell_data in snapshot.cells:
		if not cell_data.has("energy_tint_strength") or not cell_data.has("energy_activity") or not cell_data.has("energy_low"):
			failures.append("Snapshot cell missing energy render fields.")
		_expect_close(cell_data["energy_tint_strength"], snapshot.organism_energy_ratio, "cell energy tint", failures)
		match cell_data["function_id"]:
			&"energy_core":
				core_activity = maxf(core_activity, cell_data["energy_activity"])
			&"photosynthesis":
				photo_activity = maxf(photo_activity, cell_data["energy_activity"])
			&"wall":
				wall_activity = minf(wall_activity, cell_data["energy_activity"])
	if core_activity < 0.55:
		failures.append("Energy core should show storage activity.")
	if photo_activity < 0.95:
		failures.append("Photosynthesis cells should show production activity.")
	if wall_activity >= core_activity:
		failures.append("Wall activity should remain more subtle than core activity.")


func _validate_renderer_boundary(failures: Array[String]) -> void:
	var renderer_source = FileAccess.get_file_as_string("res://src/rendering/hex_organism_renderer.gd")
	for forbidden in ["SimulationService", "EnergySystem", "OrganismEnergyState"]:
		if renderer_source.contains(forbidden):
			failures.append("Renderer must not depend on %s." % forbidden)
	if not renderer_source.contains("energy_activity") or not renderer_source.contains("energy_tint_strength"):
		failures.append("Renderer should consume snapshot energy render fields.")


func _validate_lab_contract(failures: Array[String]) -> void:
	var lab_source = FileAccess.get_file_as_string("res://src/lab/starter_bacterium_lab.gd")
	if not lab_source.contains("func _process") or not lab_source.contains("tick_energy"):
		failures.append("Lab should own Slice 2 composition-root energy tick.")
	if lab_source.contains("energy_metrics[\"low_energy_ratio\"]"):
		failures.append("Lab must pass low_energy_ratio as render hints, not mutate energy metrics.")
	if lab_source.contains("TimeService"):
		failures.append("Slice 2 should not introduce TimeService autoload.")
	if not lab_source.contains("Energy:") or not lab_source.contains("Net:"):
		failures.append("Lab HUD should expose energy values.")


func _expect_close(actual: float, expected: float, label: String, failures: Array[String]) -> void:
	if absf(actual - expected) > EPS:
		failures.append("%s expected %.3f, got %.3f." % [label, expected, actual])


func _finish(label: String, failures: Array[String]) -> void:
	if failures.is_empty():
		print("%s: OK" % label)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
