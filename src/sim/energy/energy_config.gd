class_name EnergyConfig
extends Resource

@export_range(0.05, 10.0, 0.05) var tick_interval_seconds: float = 1.0
@export_range(0.0, 1.0, 0.01) var initial_energy_ratio: float = 0.5
@export_range(0.0, 1.0, 0.01) var low_energy_ratio: float = 0.25
