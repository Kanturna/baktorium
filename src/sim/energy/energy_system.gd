class_name EnergySystem
extends RefCounted


static func reset(body, catalog, state, config) -> void:
	var initial_ratio = config.initial_energy_ratio if config != null else 0.5
	state.reset(_calculate_max_energy(body, catalog), initial_ratio)


static func tick(body, catalog, state, config) -> void:
	var totals = _calculate_energy_totals(body, catalog)
	state.apply_tick(totals["max_energy"], totals["production"], totals["maintenance"])


static func _calculate_energy_totals(body, catalog) -> Dictionary:
	var production := 0.0
	var maintenance := 0.0
	var max_energy := 0.0
	if body == null or catalog == null:
		return {
			"production": production,
			"maintenance": maintenance,
			"max_energy": max_energy,
		}

	for cell in body.get_cells():
		var definition = catalog.get_definition(cell.function_id)
		if definition == null:
			continue
		production += definition.energy_production
		maintenance += definition.maintenance_cost
		max_energy += definition.energy_capacity

	return {
		"production": production,
		"maintenance": maintenance,
		"max_energy": max_energy,
	}


static func _calculate_max_energy(body, catalog) -> float:
	return _calculate_energy_totals(body, catalog)["max_energy"]
