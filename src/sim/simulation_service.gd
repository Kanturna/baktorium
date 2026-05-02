class_name SimulationService
extends Node

const CellBlock = preload("res://src/sim/body/cell_block.gd")
const HexCoord = preload("res://src/core/hex/hex_coord.gd")
const OrganismBody = preload("res://src/sim/body/organism_body.gd")

var _bodies_by_id: Dictionary = {}
var _placement_count: int = 0


func clear() -> void:
	_bodies_by_id.clear()
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


func place_cell(organism_id: int, coord, function_id: StringName, visual_seed: int = 0) -> bool:
	var body = get_body(organism_id)
	if body == null:
		body = create_organism(organism_id, visual_seed)

	var cell = CellBlock.new(coord.duplicate_coord(), function_id, visual_seed)
	var placed = body._place_cell_internal(cell)
	if placed:
		_placement_count += 1
	return placed
