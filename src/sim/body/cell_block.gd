class_name CellBlock
extends RefCounted

const HexCoord = preload("res://src/core/hex/hex_coord.gd")

var coord
var function_id: StringName
var visual_seed: int


func _init(p_coord = null, p_function_id: StringName = &"", p_visual_seed: int = 0) -> void:
	coord = p_coord if p_coord != null else HexCoord.new()
	function_id = p_function_id
	visual_seed = p_visual_seed


func duplicate_cell():
	return get_script().new(coord.duplicate_coord(), function_id, visual_seed)
