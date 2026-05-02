class_name CellFunctionCatalog
extends RefCounted

const CellFunctionDef = preload("res://src/sim/catalog/cell_function_def.gd")

var definitions_by_id: Dictionary = {}


func add_definition(definition) -> void:
	if definition == null:
		return
	definitions_by_id[definition.id] = definition


func has_function(function_id: StringName) -> bool:
	return definitions_by_id.has(function_id)


func get_definition(function_id: StringName):
	return definitions_by_id.get(function_id)


func ids() -> Array:
	var result = definitions_by_id.keys()
	result.sort()
	return result


static func default_catalog():
	var catalog = load("res://src/sim/catalog/cell_function_catalog.gd").new()
	var paths = [
		"res://resources/cell_functions/energy_core.tres",
		"res://resources/cell_functions/photosynthesis.tres",
		"res://resources/cell_functions/reproduction.tres",
		"res://resources/cell_functions/wall.tres",
	]
	for path in paths:
		var definition = load(path) as CellFunctionDef
		if definition != null:
			catalog.add_definition(definition)
	return catalog
