class_name SimulationService
extends Node

const CellBlock = preload("res://src/sim/body/cell_block.gd")
const EnergySystem = preload("res://src/sim/energy/energy_system.gd")
const HexCoord = preload("res://src/core/hex/hex_coord.gd")
const OrganismEnergyState = preload("res://src/sim/energy/organism_energy_state.gd")
const OrganismBody = preload("res://src/sim/body/organism_body.gd")

var _bodies_by_id: Dictionary = {}
var _energy_states_by_id: Dictionary = {}
var _placement_count: int = 0


func clear() -> void:
	_bodies_by_id.clear()
	_energy_states_by_id.clear()
	_placement_count = 0


func create_organism(organism_id: int, seed: int = 1):
	var body = OrganismBody.new(organism_id, seed)
	_bodies_by_id[organism_id] = body
	return body


func get_body(organism_id: int):
	return _bodies_by_id.get(organism_id)


func get_organism_ids() -> Array:
	var ids = _bodies_by_id.keys()
	ids.sort()
	return ids


func get_placement_count() -> int:
	return _placement_count


func reset_energy(organism_id: int, catalog, config) -> void:
	var body = get_body(organism_id)
	if body == null:
		return
	var state = OrganismEnergyState.new()
	EnergySystem.reset(body, catalog, state, config)
	_energy_states_by_id[organism_id] = state


func tick_energy(organism_id: int, catalog, config) -> bool:
	var body = get_body(organism_id)
	if body == null:
		return false
	if not _energy_states_by_id.has(organism_id):
		reset_energy(organism_id, catalog, config)
	var state = _energy_states_by_id.get(organism_id)
	EnergySystem.tick(body, catalog, state, config)
	return true


func get_energy_metrics(organism_id: int) -> Dictionary:
	var state = _energy_states_by_id.get(organism_id)
	if state == null:
		return {}
	return state.to_metrics().duplicate(true)


func place_cell(organism_id: int, coord, function_id: StringName, visual_seed: int = 0) -> bool:
	var body = get_body(organism_id)
	if body == null:
		body = create_organism(organism_id, visual_seed)

	var cell = CellBlock.new(coord.duplicate_coord(), function_id, visual_seed)
	var placed = body._place_cell_internal(cell)
	if placed:
		_placement_count += 1
	return placed
