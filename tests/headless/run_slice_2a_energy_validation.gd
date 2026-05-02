extends SceneTree

const CellFunctionCatalog = preload("res://src/sim/catalog/cell_function_catalog.gd")
const EnergyConfig = preload("res://src/sim/energy/energy_config.gd")
const EnergySystem = preload("res://src/sim/energy/energy_system.gd")
const HexCoord = preload("res://src/core/hex/hex_coord.gd")
const OrganismValidator = preload("res://src/sim/body/organism_validator.gd")
const SimulationService = preload("res://src/sim/simulation_service.gd")
const StarterBacteriumFactory = preload("res://src/sim/body/starter_bacterium_factory.gd")

const EPS := 0.001


func _initialize() -> void:
	var failures: Array[String] = []
	var catalog = CellFunctionCatalog.default_catalog()
	var config = EnergyConfig.new()
	var service = SimulationService.new()
	get_root().add_child(service)
	var body = StarterBacteriumFactory.new().build(service, 1, 7)

	_validate_catalog_values(catalog, failures)
	_validate_initial_energy(service, body, catalog, config, failures)
	_validate_tick(service, body, catalog, config, failures)
	_validate_clamp_and_copy(catalog, config, failures)
	_validate_service_boundaries(service, failures)
	_finish("Slice 2A energy validation", failures)


func _validate_catalog_values(catalog, failures: Array[String]) -> void:
	var core = catalog.get_definition(&"energy_core")
	var photo = catalog.get_definition(&"photosynthesis")
	var reproduction = catalog.get_definition(&"reproduction")
	var wall = catalog.get_definition(&"wall")
	_expect_close(core.energy_capacity, 30.0, "energy_core capacity", failures)
	_expect_close(core.maintenance_cost, 0.1, "energy_core maintenance", failures)
	_expect_close(photo.energy_production, 2.0, "photosynthesis production", failures)
	_expect_close(photo.maintenance_cost, 0.25, "photosynthesis maintenance", failures)
	_expect_close(reproduction.maintenance_cost, 0.35, "reproduction maintenance", failures)
	_expect_close(reproduction.growth_cost, 8.0, "reproduction growth cost", failures)
	_expect_close(wall.maintenance_cost, 0.15, "wall maintenance", failures)


func _validate_initial_energy(service, body, catalog, config, failures: Array[String]) -> void:
	service.reset_energy(1, catalog, config)
	var metrics = service.get_energy_metrics(1)
	_expect_close(metrics["max_energy"], 30.0, "initial max energy", failures)
	_expect_close(metrics["current_energy"], 15.0, "initial current energy", failures)
	_expect_close(metrics["energy_ratio"], 0.5, "initial energy ratio", failures)
	if metrics["tick_index"] != 0:
		failures.append("Initial energy tick index should be 0.")
	failures.append_array(OrganismValidator.validate_starter_body(body, catalog))


func _validate_tick(service, body, catalog, config, failures: Array[String]) -> void:
	var before_signature = _body_signature(body)
	if not service.tick_energy(1, catalog, config):
		failures.append("tick_energy should return true for existing organism.")
	var after_signature = _body_signature(body)
	if before_signature != after_signature:
		failures.append("Energy tick must not mutate body cells.")
	if not body.is_body_connected():
		failures.append("Energy tick must not break body connectedness.")

	var metrics = service.get_energy_metrics(1)
	_expect_close(metrics["last_production"], 4.0, "tick production", failures)
	_expect_close(metrics["last_maintenance"], 1.4, "tick maintenance", failures)
	_expect_close(metrics["last_net"], 2.6, "tick net", failures)
	_expect_close(metrics["current_energy"], 17.6, "current energy after one tick", failures)
	if metrics["tick_index"] != 1:
		failures.append("Tick index should be 1 after one tick.")

	var first_service = SimulationService.new()
	var second_service = SimulationService.new()
	get_root().add_child(first_service)
	get_root().add_child(second_service)
	StarterBacteriumFactory.new().build(first_service, 1, 7)
	StarterBacteriumFactory.new().build(second_service, 1, 7)
	first_service.reset_energy(1, catalog, config)
	second_service.reset_energy(1, catalog, config)
	for _i in 5:
		first_service.tick_energy(1, catalog, config)
		second_service.tick_energy(1, catalog, config)
	if first_service.get_energy_metrics(1) != second_service.get_energy_metrics(1):
		failures.append("Energy ticks should be deterministic across equivalent services.")


func _validate_clamp_and_copy(catalog, config, failures: Array[String]) -> void:
	var high_service = SimulationService.new()
	get_root().add_child(high_service)
	StarterBacteriumFactory.new().build(high_service, 1, 3)
	high_service.reset_energy(1, catalog, config)
	for _i in 100:
		high_service.tick_energy(1, catalog, config)
	_expect_close(high_service.get_energy_metrics(1)["current_energy"], 30.0, "high clamp", failures)

	var low_config = EnergyConfig.new()
	low_config.initial_energy_ratio = 0.0
	var low_service = SimulationService.new()
	get_root().add_child(low_service)
	low_service.place_cell(2, HexCoord.new(0, 0), &"energy_core")
	low_service.place_cell(2, HexCoord.new(1, 0), &"wall")
	low_service.reset_energy(2, catalog, low_config)
	low_service.tick_energy(2, catalog, low_config)
	_expect_close(low_service.get_energy_metrics(2)["current_energy"], 0.0, "low clamp", failures)

	var metrics_copy = high_service.get_energy_metrics(1)
	metrics_copy["current_energy"] = 999.0
	if high_service.get_energy_metrics(1)["current_energy"] == 999.0:
		failures.append("get_energy_metrics() must return copied read data.")


func _validate_service_boundaries(service, failures: Array[String]) -> void:
	if not service.has_method("reset_energy") or not service.has_method("tick_energy") or not service.has_method("get_energy_metrics"):
		failures.append("SimulationService missing energy public API.")
	for property in service.get_property_list():
		if property.get("name") == "energy_states_by_id":
			failures.append("SimulationService must not expose public energy_states_by_id.")

	var energy_source = FileAccess.get_file_as_string("res://src/sim/energy/energy_system.gd")
	if not energy_source.contains("static func tick"):
		failures.append("EnergySystem.tick() should be static.")
	if energy_source.contains("extends Node"):
		failures.append("EnergySystem must not be a Node or singleton.")

	var files: Array[String] = []
	_collect_gd_files("res://src", files)
	for file_path in files:
		if file_path == "res://src/sim/simulation_service.gd":
			continue
		var source = FileAccess.get_file_as_string(file_path)
		if source.contains("._energy_states_by_id") or source.contains(".energy_states_by_id"):
			failures.append("Direct energy state access outside SimulationService: %s" % file_path)


func _body_signature(body) -> String:
	var parts: Array[String] = []
	for key in body.get_cell_keys():
		var cell = body.get_cell_by_key(key)
		parts.append("%s:%s" % [key, cell.function_id])
	return "|".join(parts)


func _expect_close(actual: float, expected: float, label: String, failures: Array[String]) -> void:
	if absf(actual - expected) > EPS:
		failures.append("%s expected %.3f, got %.3f." % [label, expected, actual])


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
