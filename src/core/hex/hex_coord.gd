class_name HexCoord
extends RefCounted

const HEX_COORD_SCRIPT = preload("res://src/core/hex/hex_coord.gd")

var q: int
var r: int


func _init(p_q: int = 0, p_r: int = 0) -> void:
	q = p_q
	r = p_r


func to_key() -> String:
	return "%d,%d" % [q, r]


func equals(other) -> bool:
	return other != null and q == other.q and r == other.r


func add(other):
	return get_script().new(q + other.q, r + other.r)


func subtract(other):
	return get_script().new(q - other.q, r - other.r)


func cube_s() -> int:
	return -q - r


func duplicate_coord():
	return get_script().new(q, r)


static func from_key(key: String):
	var parts = key.split(",", false, 2)
	if parts.size() != 2:
		push_error("Invalid hex coord key: %s" % key)
		return _new_coord()
	return _new_coord(int(parts[0]), int(parts[1]))


static func _new_coord(p_q: int = 0, p_r: int = 0):
	return HEX_COORD_SCRIPT.new(p_q, p_r)


func _to_string() -> String:
	return "(%d,%d)" % [q, r]
