extends SceneTree

const CellFunctionCatalog = preload("res://src/sim/catalog/cell_function_catalog.gd")
const HexCoord = preload("res://src/core/hex/hex_coord.gd")
const HexGridMath = preload("res://src/core/hex/hex_grid_math.gd")
const HexRenderConfig = preload("res://src/rendering/hex_render_config.gd")
const OrganismSnapshotBuilder = preload("res://src/runtime/organism_snapshot_builder.gd")
const OrganismValidator = preload("res://src/sim/body/organism_validator.gd")
const SimulationService = preload("res://src/sim/simulation_service.gd")
const StarterBacteriumFactory = preload("res://src/sim/body/starter_bacterium_factory.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	_validate_hex(failures)
	_validate_body(failures)
	_validate_snapshot(failures)
	_validate_plugins(failures)
	_finish("Slice 1 validation", failures)


func _validate_hex(failures: Array[String]) -> void:
	var origin = HexCoord.new(0, 0)
	if HexGridMath.neighbors(origin).size() != 6:
		failures.append("Hex neighbor count failed.")
	if HexGridMath.distance(origin, HexCoord.new(1, -1)) != 1:
		failures.append("Hex distance failed.")


func _validate_body(failures: Array[String]) -> void:
	var catalog = CellFunctionCatalog.default_catalog()
	var service = SimulationService.new()
	get_root().add_child(service)
	var body = StarterBacteriumFactory.new().build(service, 1, 19)
	failures.append_array(OrganismValidator.validate_starter_body(body, catalog))
	if service.placement_count != 7:
		failures.append("SimulationService placement path failed.")
	if body.has_method("add_cell"):
		failures.append("OrganismBody exposes forbidden add_cell().")


func _validate_snapshot(failures: Array[String]) -> void:
	var catalog = CellFunctionCatalog.default_catalog()
	var service = SimulationService.new()
	get_root().add_child(service)
	var body = StarterBacteriumFactory.new().build(service, 1, 23)
	var snapshot = OrganismSnapshotBuilder.build(body, catalog)
	if snapshot.cell_count != 7:
		failures.append("Snapshot cell count failed.")
	if snapshot.boundary_edges.is_empty():
		failures.append("Snapshot boundary edge derivation failed.")
	var renderer_source = FileAccess.get_file_as_string("res://src/rendering/hex_organism_renderer.gd")
	if renderer_source.contains("OrganismBody") or renderer_source.contains("get_body("):
		failures.append("Renderer depends on sim body.")


func _validate_plugins(failures: Array[String]) -> void:
	var project = FileAccess.get_file_as_string("res://project.godot")
	if not project.contains("run/main_scene=\"uid://dbke7vdra2t0r\""):
		failures.append("Main scene is not set to starter bacterium lab.")
	if not project.contains("res://addons/antialiased_line2d/plugin.cfg"):
		failures.append("Antialiased Line2D plugin not enabled.")
	if not project.contains("res://addons/debug_menu/plugin.cfg"):
		failures.append("Debug Menu plugin not enabled.")
	var config = load("res://resources/render/starter_bacterium_render_config.tres") as HexRenderConfig
	if config == null or config.flow_enabled:
		failures.append("Render config missing or flow default is not false.")


func _finish(label: String, failures: Array[String]) -> void:
	if failures.is_empty():
		print("%s: OK" % label)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
