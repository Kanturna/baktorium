class_name StarterBacteriumLab
extends Node2D

const CellFunctionCatalog = preload("res://src/sim/catalog/cell_function_catalog.gd")
const DebugMenuAdapter = preload("res://src/debug/debug_menu_adapter.gd")
const HexOrganismRenderer = preload("res://src/rendering/hex_organism_renderer.gd")
const HexRenderConfig = preload("res://src/rendering/hex_render_config.gd")
const OrganismSnapshotBuilder = preload("res://src/runtime/organism_snapshot_builder.gd")
const PerfProbe = preload("res://src/debug/perf_probe.gd")
const SimulationService = preload("res://src/sim/simulation_service.gd")
const StarterBacteriumFactory = preload("res://src/sim/body/starter_bacterium_factory.gd")

const ORGANISM_ID = 1

@export var seed: int = 1
@export var render_config: Resource

var service
var catalog
var renderer
var info_label: Label
var perf_probe = PerfProbe.new()


func _ready() -> void:
	if render_config == null:
		render_config = load("res://resources/render/starter_bacterium_render_config.tres").duplicate(true)

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

	var snapshot_start = Time.get_ticks_usec()
	var snapshot = OrganismSnapshotBuilder.build(body, catalog)
	perf_probe.snapshot_build_usec = Time.get_ticks_usec() - snapshot_start
	renderer.set_snapshot(snapshot)
	_update_label()


func _update_label() -> void:
	if info_label == null:
		return
	info_label.text = "Baktorium Slice 1\nSeed: %d\nCells: %d\nBody: %dus Snapshot: %dus\nD Debug  F Flow:%s  N/B Seed  F3 DebugMenu" % [
		seed,
		perf_probe.cell_count,
		perf_probe.body_build_usec,
		perf_probe.snapshot_build_usec,
		"on" if render_config.flow_enabled else "off",
	]
