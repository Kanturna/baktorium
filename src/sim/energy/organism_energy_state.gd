class_name OrganismEnergyState
extends RefCounted

var current_energy: float = 0.0
var max_energy: float = 0.0
var last_production: float = 0.0
var last_maintenance: float = 0.0
var last_net: float = 0.0
var tick_index: int = 0
var energy_ratio: float = 0.0


func reset(p_max_energy: float, initial_ratio: float) -> void:
	max_energy = maxf(0.0, p_max_energy)
	current_energy = clampf(max_energy * clampf(initial_ratio, 0.0, 1.0), 0.0, max_energy)
	last_production = 0.0
	last_maintenance = 0.0
	last_net = 0.0
	tick_index = 0
	_update_ratio()


func apply_tick(p_max_energy: float, production: float, maintenance: float) -> void:
	max_energy = maxf(0.0, p_max_energy)
	last_production = maxf(0.0, production)
	last_maintenance = maxf(0.0, maintenance)
	last_net = last_production - last_maintenance
	current_energy = clampf(current_energy + last_net, 0.0, max_energy)
	tick_index += 1
	_update_ratio()


func to_metrics() -> Dictionary:
	return {
		"current_energy": current_energy,
		"max_energy": max_energy,
		"last_production": last_production,
		"last_maintenance": last_maintenance,
		"last_net": last_net,
		"tick_index": tick_index,
		"energy_ratio": energy_ratio,
	}


func _update_ratio() -> void:
	energy_ratio = current_energy / max_energy if max_energy > 0.0 else 0.0
