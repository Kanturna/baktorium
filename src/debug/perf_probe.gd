class_name PerfProbe
extends RefCounted

var cell_count: int = 0
var body_build_usec: int = 0
var snapshot_build_usec: int = 0
var energy_tick_usec: int = 0


func reset() -> void:
	cell_count = 0
	body_build_usec = 0
	snapshot_build_usec = 0
	energy_tick_usec = 0
