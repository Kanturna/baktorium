extends SceneTree

const CellFunctionCatalog = preload("res://src/sim/catalog/cell_function_catalog.gd")
const EnergyConfig = preload("res://src/sim/energy/energy_config.gd")
const HexCoord = preload("res://src/core/hex/hex_coord.gd")
const HexGridMath = preload("res://src/core/hex/hex_grid_math.gd")
const SimulationService = preload("res://src/sim/simulation_service.gd")

const ORGANISM_ID := 99
const CELL_TARGET := 100
const TICK_COUNT := 100
const AVG_TICK_GATE_MSEC := 1.0
const EPS := 0.001


func _initialize() -> void:
	var failures: Array[String] = []
	var catalog = CellFunctionCatalog.default_catalog()
	var config = EnergyConfig.new()
	var first = _run_stress(catalog, config)
	var second = _run_stress(catalog, config)

	if first["cell_count"] != CELL_TARGET:
		failures.append("Stress body should contain %d cells, got %d." % [CELL_TARGET, first["cell_count"]])
	if first["avg_msec"] >= AVG_TICK_GATE_MSEC:
		failures.append("Average energy tick should be < %.2f ms, got %.3f ms." % [AVG_TICK_GATE_MSEC, first["avg_msec"]])
	for key in ["current_energy", "max_energy", "last_production", "last_maintenance", "last_net", "energy_ratio"]:
		if _is_bad_number(first["metrics"][key]):
			failures.append("Stress metric %s is NaN or Inf." % key)
	if first["signature"] != second["signature"]:
		failures.append("Stress energy ticks should be deterministic.")

	_finish("Slice 2 stress validation", failures)


func _run_stress(catalog, config) -> Dictionary:
	var service = SimulationService.new()
	get_root().add_child(service)
	_build_cluster(service)
	service.reset_energy(ORGANISM_ID, catalog, config)
	var started = Time.get_ticks_usec()
	for _i in TICK_COUNT:
		service.tick_energy(ORGANISM_ID, catalog, config)
	var elapsed = Time.get_ticks_usec() - started
	var metrics = service.get_energy_metrics(ORGANISM_ID)
	var body = service.get_body(ORGANISM_ID)
	return {
		"cell_count": body.get_cell_count(),
		"avg_msec": float(elapsed) / 1000.0 / float(TICK_COUNT),
		"metrics": metrics,
		"signature": _metrics_signature(metrics),
	}


func _build_cluster(service) -> void:
	var queue: Array = [HexCoord.new(0, 0)]
	var queued := {"0,0": true}
	var placed := 0
	while not queue.is_empty() and placed < CELL_TARGET:
		var coord = queue.pop_front()
		service.place_cell(ORGANISM_ID, coord, _function_for_index(placed), placed)
		placed += 1
		for neighbor in HexGridMath.neighbors(coord):
			var key = neighbor.to_key()
			if not queued.has(key):
				queued[key] = true
				queue.append(neighbor)


func _function_for_index(index: int) -> StringName:
	if index == 0:
		return &"energy_core"
	if index % 5 == 0:
		return &"photosynthesis"
	return &"wall"


func _metrics_signature(metrics: Dictionary) -> String:
	return "%.3f|%.3f|%.3f|%.3f|%.3f|%d" % [
		metrics["current_energy"],
		metrics["max_energy"],
		metrics["last_production"],
		metrics["last_maintenance"],
		metrics["last_net"],
		metrics["tick_index"],
	]


func _is_bad_number(value: float) -> bool:
	return value != value or absf(value) == INF


func _finish(label: String, failures: Array[String]) -> void:
	if failures.is_empty():
		print("%s: OK" % label)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
