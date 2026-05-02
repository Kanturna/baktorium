extends SceneTree

const CellFunctionCatalog = preload("res://src/sim/catalog/cell_function_catalog.gd")
const EnergyConfig = preload("res://src/sim/energy/energy_config.gd")
const OrganismSnapshotBuilder = preload("res://src/runtime/organism_snapshot_builder.gd")
const SimulationService = preload("res://src/sim/simulation_service.gd")
const StarterBacteriumFactory = preload("res://src/sim/body/starter_bacterium_factory.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	_validate_end_to_end_snapshot(failures)
	_validate_docs(failures)
	_validate_png_cleanup_gate(failures)
	_finish("Polish Iter A integration validation", failures)


func _validate_end_to_end_snapshot(failures: Array[String]) -> void:
	var catalog = CellFunctionCatalog.default_catalog()
	var config = EnergyConfig.new()
	var service = SimulationService.new()
	get_root().add_child(service)
	var body = StarterBacteriumFactory.new().build(service, 1, 51)
	service.reset_energy(1, catalog, config)
	service.tick_energy(1, catalog, config)
	var snapshot = OrganismSnapshotBuilder.build(body, catalog, service.get_energy_metrics(1), {"low_energy_ratio": config.low_energy_ratio})
	if snapshot.cell_count != 7:
		failures.append("Polish must keep starter body at 7 cells.")
	for cell_data in snapshot.cells:
		if cell_data["sprite_texture"] == null:
			failures.append("Every starter cell should resolve a beauty sprite texture.")
		if cell_data["sprite_frames"] == null:
			failures.append("Every selected Iter-A cell type should resolve sprite frames.")
		if cell_data.has("cell_ref") or cell_data.has("body"):
			failures.append("Snapshot must not expose mutable body data.")


func _validate_docs(failures: Array[String]) -> void:
	var architecture = FileAccess.get_file_as_string("res://docs/ARCHITEKTUR.md")
	var decisions = FileAccess.get_file_as_string("res://docs/DECISIONS.md")
	var status = FileAccess.get_file_as_string("res://docs/STATUS.md")
	var next_steps = FileAccess.get_file_as_string("res://docs/NEXT_STEPS.md")
	var findings = FileAccess.get_file_as_string("res://docs/FINDINGS.md")
	for required in ["Visual Truth Contract", "Simulation Truth vs Visual Truth"]:
		if not architecture.contains(required):
			failures.append("ARCHITEKTUR.md missing %s." % required)
	for required in ["ADR-010", "ADR-011", "Mipmaps", "outer_sprite_frames", "inner_sprite_frames"]:
		if not decisions.contains(required):
			failures.append("DECISIONS.md missing %s." % required)
	if not status.contains("Slice 2 Polish Iter A"):
		failures.append("STATUS.md missing Polish Iter A status.")
	if not status.contains("Slice 2 Polish Iter B0"):
		failures.append("STATUS.md missing Polish Iter B0 status.")
	if not next_steps.contains("Beauty/Debug") or not next_steps.contains("100-cell"):
		failures.append("NEXT_STEPS.md missing Beauty/Debug or 100-cell manual gates.")
	if not next_steps.contains("checkerboard") or not decisions.contains("normalize_cell_spritesheets"):
		failures.append("Docs should include Iter B0 normalization and checkerboard gates.")
	if not findings.contains("Hex-radius") or not findings.contains("Particle adapter"):
		failures.append("FINDINGS.md missing Iter-A future findings.")
	if not findings.contains("Slice 2 Polish Iter B0"):
		failures.append("FINDINGS.md missing Iter B0 resolved findings.")


func _validate_png_cleanup_gate(failures: Array[String]) -> void:
	if DirAccess.open("res://png") == null:
		failures.append("png/ should remain until manual Beauty sign-off; cleanup gate would be untraceable if it is already gone.")


func _finish(label: String, failures: Array[String]) -> void:
	if failures.is_empty():
		print("%s: OK" % label)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
