class_name StarterBacteriumFactory
extends RefCounted

const HexCoord = preload("res://src/core/hex/hex_coord.gd")
const OrganismBody = preload("res://src/sim/body/organism_body.gd")
const SimulationService = preload("res://src/sim/simulation_service.gd")

const ORGANISM_ID = 1

const STARTER_LAYOUT = [
	[0, 0, &"energy_core"],
	[1, 0, &"photosynthesis"],
	[0, 1, &"photosynthesis"],
	[-1, 0, &"reproduction"],
	[1, -1, &"wall"],
	[0, -1, &"wall"],
	[-1, 1, &"wall"],
]


func build(service, organism_id: int = ORGANISM_ID, seed: int = 1):
	service.create_organism(organism_id, seed)
	for index in STARTER_LAYOUT.size():
		var item: Array = STARTER_LAYOUT[index]
		var coord = HexCoord.new(item[0], item[1])
		var function_id: StringName = item[2]
		service.place_cell(organism_id, coord, function_id, seed + index * 97)
	return service.get_body(organism_id)
