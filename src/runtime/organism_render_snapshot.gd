class_name OrganismRenderSnapshot
extends RefCounted

var organism_id: int
var seed: int
var cells: Array = []
var boundary_edges: Array = []
var cell_count: int = 0


func _init(p_organism_id: int = 0, p_seed: int = 0) -> void:
	organism_id = p_organism_id
	seed = p_seed

