extends SceneTree

const CellFunctionCatalog = preload("res://src/sim/catalog/cell_function_catalog.gd")
const Genome = preload("res://src/genetics/genome.gd")
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
	_finish("Slice 1B body validation", failures)


func _validate_body_api(body, failures: Array[String]) -> void:
	if body.has_method("add_cell"):
		failures.append("OrganismBody must not expose public add_cell().")
	if not body.has_method("_place_cell_internal"):
		failures.append("OrganismBody must expose internal _place_cell_internal() for SimulationService only.")


func _validate_starter_body(body, catalog, failures: Array[String]) -> void:
	failures.append_array(OrganismValidator.validate_starter_body(body, catalog))
	if body.get_boundary_edges().is_empty():
		failures.append("Starter body should have boundary edges.")


func _validate_catalog(catalog, failures: Array[String]) -> void:
	for id in [&"energy_core", &"photosynthesis", &"reproduction", &"wall"]:
		if not catalog.has_function(id):
			failures.append("Catalog missing %s." % id)


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
	if service.placement_count != 7:
		failures.append("Starter factory should place exactly 7 cells through SimulationService; got %d." % service.placement_count)
	var source = FileAccess.get_file_as_string("res://src/sim/body/starter_bacterium_factory.gd")
	if source.contains("._place_cell_internal") or source.contains(".add_cell"):
		failures.append("StarterBacteriumFactory must not place cells through OrganismBody directly.")


func _finish(label: String, failures: Array[String]) -> void:
	if failures.is_empty():
		print("%s: OK" % label)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
