extends SceneTree

const CellFunctionCatalog = preload("res://src/sim/catalog/cell_function_catalog.gd")
const Genome = preload("res://src/genetics/genome.gd")
const HexCoord = preload("res://src/core/hex/hex_coord.gd")
const HexGridMath = preload("res://src/core/hex/hex_grid_math.gd")
const OrganismBody = preload("res://src/sim/body/organism_body.gd")
const OrganismValidator = preload("res://src/sim/body/organism_validator.gd")
const SimulationService = preload("res://src/sim/simulation_service.gd")
const StarterBacteriumFactory = preload("res://src/sim/body/starter_bacterium_factory.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	var catalog = CellFunctionCatalog.default_catalog()
	var service = SimulationService.new()
	get_root().add_child(service)
	var body = StarterBacteriumFactory.new().build(service, 1, 7)

	_validate_body_api(body, failures)
	_validate_starter_body(body, catalog, failures)
	_validate_catalog(catalog, failures)
	_validate_genome_schema(failures)
	_validate_factory_uses_service(service, failures)
	_validate_connectivity_and_boundary_cases(failures)
	_finish("Slice 1B body validation", failures)


func _validate_body_api(body, failures: Array[String]) -> void:
	if body.has_method("add_cell"):
		failures.append("OrganismBody must not expose public add_cell().")
	if not body.has_method("_place_cell_internal"):
		failures.append("OrganismBody must expose internal _place_cell_internal() for SimulationService only.")
	for property in body.get_property_list():
		if property.get("name") == "cells_by_key":
			failures.append("OrganismBody must not expose public cells_by_key.")


func _validate_starter_body(body, catalog, failures: Array[String]) -> void:
	failures.append_array(OrganismValidator.validate_starter_body(body, catalog))
	if body.get_boundary_edges().is_empty():
		failures.append("Starter body should have boundary edges.")


func _validate_catalog(catalog, failures: Array[String]) -> void:
	for id in [&"energy_core", &"photosynthesis", &"reproduction", &"wall"]:
		if not catalog.has_function(id):
			failures.append("Catalog missing %s." % id)
	var energy = catalog.get_definition(&"energy_core")
	var photo = catalog.get_definition(&"photosynthesis")
	var reproduction = catalog.get_definition(&"reproduction")
	var wall = catalog.get_definition(&"wall")
	if energy == null or energy.accent_kind != "glow_disc":
		failures.append("energy_core should define glow_disc accent metadata.")
	if photo == null or photo.accent_kind != "surface_dot" or not photo.requires_surface:
		failures.append("photosynthesis should define surface_dot accent metadata and require surface.")
	if reproduction == null or reproduction.accent_kind != "ring_arc" or not reproduction.requires_surface:
		failures.append("reproduction should define ring_arc accent metadata and require surface.")
	if wall == null or wall.boundary_outline_scale <= 1.0 or not wall.requires_surface:
		failures.append("wall should define stronger boundary outline metadata and require surface.")


func _validate_genome_schema(failures: Array[String]) -> void:
	var genome = Genome.new()
	for property in [
		"photosynthesis_bias",
		"wall_bias",
		"reproduction_bias",
		"growth_spread",
		"symmetry_bias",
		"surface_preference",
		"energy_efficiency",
		"mutation_rate",
	]:
		if genome.get(property) == null:
			failures.append("Genome missing property %s." % property)


func _validate_factory_uses_service(service, failures: Array[String]) -> void:
	if service.get_placement_count() != 7:
		failures.append("Starter factory should place exactly 7 cells through SimulationService; got %d." % service.get_placement_count())
	for property in service.get_property_list():
		if property.get("name") in ["bodies_by_id", "placement_count"]:
			failures.append("SimulationService must not expose public %s." % property.get("name"))
	var source = FileAccess.get_file_as_string("res://src/sim/body/starter_bacterium_factory.gd")
	if source.contains("._place_cell_internal") or source.contains(".add_cell"):
		failures.append("StarterBacteriumFactory must not place cells through OrganismBody directly.")


func _validate_connectivity_and_boundary_cases(failures: Array[String]) -> void:
	var line_service = SimulationService.new()
	get_root().add_child(line_service)
	line_service.create_organism(2, 2)
	line_service.place_cell(2, HexCoord.new(0, 0), &"wall")
	line_service.place_cell(2, HexCoord.new(1, 0), &"wall")
	line_service.place_cell(2, HexCoord.new(2, 0), &"wall")
	if not line_service.get_body(2).is_body_connected():
		failures.append("Three-cell line should be connected.")

	var gap_service = SimulationService.new()
	get_root().add_child(gap_service)
	gap_service.create_organism(3, 3)
	gap_service.place_cell(3, HexCoord.new(0, 0), &"wall")
	gap_service.place_cell(3, HexCoord.new(2, 0), &"wall")
	if gap_service.get_body(3).is_body_connected():
		failures.append("Two cells with one hex gap should not be connected.")

	var isolated_service = SimulationService.new()
	get_root().add_child(isolated_service)
	isolated_service.create_organism(4, 4)
	isolated_service.place_cell(4, HexCoord.new(0, 0), &"wall")
	var isolated_body = isolated_service.get_body(4)
	if not isolated_body.is_boundary_cell(HexCoord.new(0, 0)):
		failures.append("Isolated cell should be a boundary cell.")
	if isolated_body.get_boundary_edges().size() != 6:
		failures.append("Isolated cell should expose 6 boundary edges.")

	var ring_service = SimulationService.new()
	get_root().add_child(ring_service)
	ring_service.create_organism(5, 5)
	for coord in HexGridMath.neighbors(HexCoord.new(0, 0)):
		ring_service.place_cell(5, coord, &"wall")
	var ring_body = ring_service.get_body(5)
	if ring_body.get_cell_count() != 6:
		failures.append("Radius-1 ring should contain 6 cells.")
	for cell in ring_body.get_cells():
		if not ring_body.is_boundary_cell(cell.coord):
			failures.append("Ring cell %s should be boundary." % cell.coord.to_key())


func _finish(label: String, failures: Array[String]) -> void:
	if failures.is_empty():
		print("%s: OK" % label)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
