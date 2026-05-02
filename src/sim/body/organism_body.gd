class_name OrganismBody
extends RefCounted

const CellBlock = preload("res://src/sim/body/cell_block.gd")
const HexCoord = preload("res://src/core/hex/hex_coord.gd")
const HexGridMath = preload("res://src/core/hex/hex_grid_math.gd")

var organism_id: int
var seed: int
var cells_by_key: Dictionary = {}


func _init(p_organism_id: int = 1, p_seed: int = 1) -> void:
	organism_id = p_organism_id
	seed = p_seed


func _place_cell_internal(cell) -> bool:
	var key = cell.coord.to_key()
	if cells_by_key.has(key):
		return false
	cells_by_key[key] = cell
	return true


func has_cell(coord) -> bool:
	return cells_by_key.has(coord.to_key())


func get_cell(coord):
	return cells_by_key.get(coord.to_key())


func get_cells() -> Array:
	return cells_by_key.values()


func get_cell_count() -> int:
	return cells_by_key.size()


func get_boundary_edges() -> Array:
	var edges: Array = []
	for cell in get_cells():
		for direction_index in HexGridMath.DIRECTIONS.size():
			var neighbor_coord = HexGridMath.neighbor(cell.coord, direction_index)
			if not has_cell(neighbor_coord):
				edges.append({
					"coord": cell.coord.duplicate_coord(),
					"direction": direction_index,
					"function_id": cell.function_id,
				})
	return edges


func is_boundary_cell(coord) -> bool:
	if not has_cell(coord):
		return false
	for neighbor_coord in HexGridMath.neighbors(coord):
		if not has_cell(neighbor_coord):
			return true
	return false


func is_body_connected() -> bool:
	if cells_by_key.is_empty():
		return true

	var keys = cells_by_key.keys()
	var start_key: String = keys[0]
	var visited = {}
	var queue: Array[String] = [start_key]
	visited[start_key] = true

	while not queue.is_empty():
		var current_key: String = queue.pop_front()
		var current_cell = cells_by_key[current_key]
		for neighbor_coord in HexGridMath.neighbors(current_cell.coord):
			var neighbor_key = neighbor_coord.to_key()
			if cells_by_key.has(neighbor_key) and not visited.has(neighbor_key):
				visited[neighbor_key] = true
				queue.append(neighbor_key)

	return visited.size() == cells_by_key.size()
