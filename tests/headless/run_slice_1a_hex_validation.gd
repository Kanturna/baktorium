extends SceneTree

const HexCoord = preload("res://src/core/hex/hex_coord.gd")
const HexGridMath = preload("res://src/core/hex/hex_grid_math.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	_validate_neighbors(failures)
	_validate_distance(failures)
	_validate_pixel_mapping(failures)
	_validate_key_roundtrip(failures)
	_finish("Slice 1A hex validation", failures)


func _validate_neighbors(failures: Array[String]) -> void:
	var origin = HexCoord.new(0, 0)
	var neighbors = HexGridMath.neighbors(origin)
	var expected = ["1,0", "1,-1", "0,-1", "-1,0", "-1,1", "0,1"]
	if neighbors.size() != 6:
		failures.append("Expected 6 neighbors, found %d." % neighbors.size())
	for index in expected.size():
		if neighbors[index].to_key() != expected[index]:
			failures.append("Neighbor %d expected %s, found %s." % [index, expected[index], neighbors[index].to_key()])


func _validate_distance(failures: Array[String]) -> void:
	var origin = HexCoord.new(0, 0)
	if HexGridMath.distance(origin, HexCoord.new(0, 0)) != 0:
		failures.append("Origin distance should be 0.")
	if HexGridMath.distance(origin, HexCoord.new(1, 0)) != 1:
		failures.append("Adjacent distance should be 1.")
	if HexGridMath.distance(HexCoord.new(-1, 1), HexCoord.new(1, -1)) != 2:
		failures.append("Known distance should be 2.")


func _validate_pixel_mapping(failures: Array[String]) -> void:
	var origin_pixel = HexGridMath.hex_to_pixel(HexCoord.new(0, 0), 42.0, true)
	if origin_pixel.length() > 0.001:
		failures.append("Origin pixel mapping should be zero.")
	var polygon = HexGridMath.polygon_points(42.0, true)
	if polygon.size() != 6:
		failures.append("Hex polygon should have 6 points.")


func _validate_key_roundtrip(failures: Array[String]) -> void:
	var coord = HexCoord.from_key("-2,3")
	if coord.q != -2 or coord.r != 3:
		failures.append("HexCoord.from_key() should round-trip q/r.")
	if coord.to_key() != "-2,3":
		failures.append("HexCoord.to_key() should round-trip from_key().")


func _finish(label: String, failures: Array[String]) -> void:
	if failures.is_empty():
		print("%s: OK" % label)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
