class_name StarterBacteriumLab
extends Node2D

const CellFunctionCatalog = preload("res://src/sim/catalog/cell_function_catalog.gd")
const DebugMenuAdapter = preload("res://src/debug/debug_menu_adapter.gd")
const EnergyConfig = preload("res://src/sim/energy/energy_config.gd")
const HexOrganismRenderer = preload("res://src/rendering/hex_organism_renderer.gd")
const HexRenderConfig = preload("res://src/rendering/hex_render_config.gd")
const OrganismSnapshotBuilder = preload("res://src/runtime/organism_snapshot_builder.gd")
const PerfProbe = preload("res://src/debug/perf_probe.gd")
const SimulationService = preload("res://src/sim/simulation_service.gd")
const StarterBacteriumFactory = preload("res://src/sim/body/starter_bacterium_factory.gd")

const ORGANISM_ID = 1

@export var seed: int = 1
@export var render_config: HexRenderConfig
@export var energy_config: EnergyConfig

var service: SimulationService
var catalog: CellFunctionCatalog
var renderer: HexOrganismRenderer
var info_label: Label
var perf_probe = PerfProbe.new()
var energy_accumulator: float = 0.0


func _ready() -> void:
	if render_config == null:
		render_config = load("res://resources/render/starter_bacterium_render_config.tres").duplicate(true)
	if energy_config == null:
		energy_config = load("res://resources/sim/starter_energy_config.tres").duplicate(true)

	catalog = CellFunctionCatalog.default_catalog()
	service = SimulationService.new()
	service.name = "SimulationService"
	add_child(service)

	renderer = HexOrganismRenderer.new()
	renderer.name = "HexOrganismRenderer"
	renderer.position = get_viewport_rect().size * 0.5
	renderer.set_render_config(render_config)
	add_child(renderer)

	var camera = Camera2D.new()
	camera.name = "Camera2D"
	camera.enabled = true
	camera.position = get_viewport_rect().size * 0.5
	add_child(camera)

	_create_ui()
	_rebuild()


func _process(delta: float) -> void:
	if service == null or catalog == null or energy_config == null:
		return
	energy_accumulator += delta
	var tick_interval = maxf(0.05, energy_config.tick_interval_seconds)
	var ticked = false
	while energy_accumulator >= tick_interval:
		energy_accumulator -= tick_interval
		var tick_start = Time.get_ticks_usec()
		if service.tick_energy(ORGANISM_ID, catalog, energy_config):
			perf_probe.energy_tick_usec = Time.get_ticks_usec() - tick_start
			ticked = true
	if ticked:
		_refresh_snapshot()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return

	match event.keycode:
		KEY_N:
			seed += 1
			_rebuild()
		KEY_B:
			seed = max(1, seed - 1)
			_rebuild()
		KEY_R:
			seed = int(Time.get_unix_time_from_system()) % 100000
			_rebuild()
		KEY_D:
			render_config.show_debug_overlay = not render_config.show_debug_overlay
			renderer.queue_redraw()
			_update_label()
		KEY_F:
			render_config.flow_enabled = not render_config.flow_enabled
			renderer.queue_redraw()
			_update_label()
		KEY_F3:
			DebugMenuAdapter.toggle(self)


func _create_ui() -> void:
	var layer = CanvasLayer.new()
	layer.name = "LabUI"
	add_child(layer)

	info_label = Label.new()
	info_label.name = "InfoLabel"
	info_label.position = Vector2(18, 16)
	info_label.add_theme_font_size_override("font_size", 14)
	layer.add_child(info_label)


func _rebuild() -> void:
	perf_probe.reset()
	var body_start = Time.get_ticks_usec()
	service.clear()
	var body = StarterBacteriumFactory.new().build(service, ORGANISM_ID, seed)
	perf_probe.body_build_usec = Time.get_ticks_usec() - body_start
	perf_probe.cell_count = body.get_cell_count()
	service.reset_energy(ORGANISM_ID, catalog, energy_config)
	energy_accumulator = 0.0
	_refresh_snapshot()


func _refresh_snapshot() -> void:
	var body = service.get_body(ORGANISM_ID)
	if body == null:
		return
	var snapshot_start = Time.get_ticks_usec()
	var energy_metrics = service.get_energy_metrics(ORGANISM_ID)
	var render_hints = {"low_energy_ratio": energy_config.low_energy_ratio}
	var snapshot = OrganismSnapshotBuilder.build(body, catalog, energy_metrics, render_hints)
	perf_probe.snapshot_build_usec = Time.get_ticks_usec() - snapshot_start
	renderer.set_snapshot(snapshot)
	_update_label()


func _update_label() -> void:
	if info_label == null:
		return
	var energy_metrics = service.get_energy_metrics(ORGANISM_ID) if service != null else {}
	var current_energy = float(energy_metrics.get("current_energy", 0.0))
	var max_energy = float(energy_metrics.get("max_energy", 0.0))
	var energy_ratio = float(energy_metrics.get("energy_ratio", 0.0))
	var low_marker = " LOW" if max_energy > 0.0 and energy_ratio <= energy_config.low_energy_ratio else ""
	info_label.text = "Baktorium Slice 2\nSeed: %d\nCells: %d\nEnergy: %.1f/%.1f%s\nProd: %.1f  Maint: %.1f  Net: %.1f  Tick: %d\nBody: %dus Energy: %dus Snapshot: %dus\nD Debug  F Flow:%s  N/B/R Seed  F3 DebugMenu" % [
		seed,
		perf_probe.cell_count,
		current_energy,
		max_energy,
		low_marker,
		float(energy_metrics.get("last_production", 0.0)),
		float(energy_metrics.get("last_maintenance", 0.0)),
		float(energy_metrics.get("last_net", 0.0)),
		int(energy_metrics.get("tick_index", 0)),
		perf_probe.body_build_usec,
		perf_probe.energy_tick_usec,
		perf_probe.snapshot_build_usec,
		"on" if render_config.flow_enabled else "off",
	]
