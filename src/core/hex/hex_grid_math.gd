class_name HexGridMath
extends RefCounted

const HexCoord = preload("res://src/core/hex/hex_coord.gd")

const DIRECTIONS: Array[Vector2i] = [
	Vector2i(1, 0),
	Vector2i(1, -1),
	Vector2i(0, -1),
	Vector2i(-1, 0),
	Vector2i(-1, 1),
	Vector2i(0, 1),
]


static func neighbor(coord, direction_index: int):
	var dir: Vector2i = DIRECTIONS[wrapi(direction_index, 0, DIRECTIONS.size())]
	return HexCoord.new(coord.q + dir.x, coord.r + dir.y)


static func neighbors(coord) -> Array:
	var result: Array = []
	for index in DIRECTIONS.size():
		result.append(neighbor(coord, index))
	return result


static func distance(a, b) -> int:
	var dq: int = abs(a.q - b.q)
	var dr: int = abs(a.r - b.r)
	var ds: int = abs(a.cube_s() - b.cube_s())
	return int((dq + dr + ds) / 2)


static func hex_to_pixel(coord, radius: float, pointy_top: bool = true) -> Vector2:
	if pointy_top:
		var x = radius * sqrt(3.0) * (float(coord.q) + float(coord.r) * 0.5)
		var y = radius * 1.5 * float(coord.r)
		return Vector2(x, y)

	var x_flat = radius * 1.5 * float(coord.q)
	var y_flat = radius * sqrt(3.0) * (float(coord.r) + float(coord.q) * 0.5)
	return Vector2(x_flat, y_flat)


static func polygon_points(radius: float, pointy_top: bool = true) -> PackedVector2Array:
	var points = PackedVector2Array()
	var offset_degrees = -30.0 if pointy_top else 0.0
	for index in range(6):
		var angle = deg_to_rad(offset_degrees + 60.0 * float(index))
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	return points


static func sorted_keys_for_coords(coords: Array) -> Array:
	var keys: Array = []
	for coord in coords:
		keys.append(coord.to_key())
	keys.sort()
	return keys
