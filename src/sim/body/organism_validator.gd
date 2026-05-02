class_name OrganismValidator
extends RefCounted

const CellBlock = preload("res://src/sim/body/cell_block.gd")
const CellFunctionCatalog = preload("res://src/sim/catalog/cell_function_catalog.gd")
const OrganismBody = preload("res://src/sim/body/organism_body.gd")


static func validate(body, catalog) -> Array:
	var errors: Array = []
	if body == null:
		return ["Body is null."]
	if body.get_cell_count() == 0:
		errors.append("Body has no cells.")
	if not body.is_body_connected():
		errors.append("Body is not connected.")

	var seen = {}
	for cell in body.get_cells():
		var key = cell.coord.to_key()
		if seen.has(key):
			errors.append("Duplicate cell at %s." % key)
		seen[key] = true
		if catalog != null and not catalog.has_function(cell.function_id):
			errors.append("Unknown function id: %s." % cell.function_id)

	return errors


static func validate_starter_body(body, catalog) -> Array:
	var errors = validate(body, catalog)
	var expected = {
		"0,0": &"energy_core",
		"1,0": &"photosynthesis",
		"0,1": &"photosynthesis",
		"-1,0": &"reproduction",
		"1,-1": &"wall",
		"0,-1": &"wall",
		"-1,1": &"wall",
	}

	if body.get_cell_count() != expected.size():
		errors.append("Starter body expected %d cells, found %d." % [expected.size(), body.get_cell_count()])

	for key in expected.keys():
		var cell = body.get_cell_by_key(key)
		if cell == null:
			errors.append("Missing starter cell at %s." % key)
		elif cell.function_id != expected[key]:
			errors.append("Starter cell at %s expected %s, found %s." % [key, expected[key], cell.function_id])

	return errors
