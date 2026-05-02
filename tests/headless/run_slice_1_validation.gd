extends SceneTree

const CellFunctionCatalog = preload("res://src/sim/catalog/cell_function_catalog.gd")
const HexRenderConfig = preload("res://src/rendering/hex_render_config.gd")
const OrganismSnapshotBuilder = preload("res://src/runtime/organism_snapshot_builder.gd")
const OrganismValidator = preload("res://src/sim/body/organism_validator.gd")
const SimulationService = preload("res://src/sim/simulation_service.gd")
const StarterBacteriumFactory = preload("res://src/sim/body/starter_bacterium_factory.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	_validate_end_to_end_determinism(failures)
	_validate_public_body_surface(failures)
	_validate_source_boundaries(failures)
	_validate_project_entrypoint(failures)
	_finish("Slice 1 integration validation", failures)


func _validate_end_to_end_determinism(failures: Array[String]) -> void:
	var first = _snapshot_signature(41)
	var second = _snapshot_signature(41)
	var third = _snapshot_signature(42)
	if first != second:
		failures.append("Same seed should build the same render snapshot.")
	if first == third:
		failures.append("Different seeds should produce a distinct visual snapshot signature.")


func _snapshot_signature(seed: int) -> String:
	var catalog = CellFunctionCatalog.default_catalog()
	var service = SimulationService.new()
	get_root().add_child(service)
	var body = StarterBacteriumFactory.new().build(service, 1, seed)
	var errors = OrganismValidator.validate_starter_body(body, catalog)
	if not errors.is_empty():
		return "invalid:%s" % ";".join(errors)
	var snapshot = OrganismSnapshotBuilder.build(body, catalog)
	var parts: Array[String] = []
	for cell in snapshot.cells:
		parts.append("%d,%d:%s:%d" % [cell["q"], cell["r"], cell["function_id"], cell["visual_seed"]])
	parts.append("edges:%d" % snapshot.boundary_edges.size())
	return "|".join(parts)


func _validate_public_body_surface(failures: Array[String]) -> void:
	var service = SimulationService.new()
	get_root().add_child(service)
	var body = StarterBacteriumFactory.new().build(service, 1, 19)
	if service.get_placement_count() != 7:
		failures.append("SimulationService placement path failed.")
	if body.has_method("add_cell"):
		failures.append("OrganismBody exposes forbidden add_cell().")
	for property in body.get_property_list():
		if property.get("name") == "cells_by_key":
			failures.append("OrganismBody exposes public cells_by_key.")
	for property in service.get_property_list():
		if property.get("name") in ["bodies_by_id", "placement_count"]:
			failures.append("SimulationService exposes public %s." % property.get("name"))


func _validate_source_boundaries(failures: Array[String]) -> void:
	var renderer_source = FileAccess.get_file_as_string("res://src/rendering/hex_organism_renderer.gd")
	if renderer_source.contains("OrganismBody") or renderer_source.contains("get_body("):
		failures.append("Renderer depends on sim body.")

	var files: Array[String] = []
	_collect_gd_files("res://src", files)
	for file_path in files:
		if file_path.ends_with("organism_body.gd"):
			continue
		var source = FileAccess.get_file_as_string(file_path)
		if source.contains(".cells_by_key"):
			failures.append("Direct cells_by_key access outside OrganismBody: %s" % file_path)
		if file_path != "res://src/sim/simulation_service.gd":
			if source.contains(".bodies_by_id") or source.contains(".placement_count"):
				failures.append("Direct SimulationService state access outside SimulationService: %s" % file_path)


func _validate_project_entrypoint(failures: Array[String]) -> void:
	var project = FileAccess.get_file_as_string("res://project.godot")
	if not project.contains("run/main_scene=\"res://scenes/lab/starter_bacterium_lab.tscn\""):
		failures.append("Main scene is not set to starter bacterium lab.")
	if not project.contains("res://addons/antialiased_line2d/plugin.cfg"):
		failures.append("Antialiased Line2D plugin not enabled.")
	if not project.contains("res://addons/debug_menu/plugin.cfg"):
		failures.append("Debug Menu plugin not enabled.")
	var scene = load("res://scenes/lab/starter_bacterium_lab.tscn")
	if scene == null:
		failures.append("Starter bacterium lab scene does not load.")
	var config = load("res://resources/render/starter_bacterium_render_config.tres") as HexRenderConfig
	if config == null or config.flow_enabled:
		failures.append("Render config missing or flow default is not false.")


func _collect_gd_files(path: String, files: Array[String]) -> void:
	var dir = DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var entry = dir.get_next()
	while entry != "":
		if entry.begins_with("."):
			entry = dir.get_next()
			continue
		var child_path = "%s/%s" % [path, entry]
		if dir.current_is_dir():
			_collect_gd_files(child_path, files)
		elif entry.ends_with(".gd"):
			files.append(child_path)
		entry = dir.get_next()


func _finish(label: String, failures: Array[String]) -> void:
	if failures.is_empty():
		print("%s: OK" % label)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
