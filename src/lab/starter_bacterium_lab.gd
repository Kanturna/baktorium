class_name StarterBacteriumLab
extends Node2D

const CellFunctionCatalog = preload("res://src/sim/catalog/cell_function_catalog.gd")
const DebugMenuAdapter = preload("res://src/debug/debug_menu_adapter.gd")
const EnergyConfig = preload("res://src/sim/energy/energy_config.gd")
const HexCoord = preload("res://src/core/hex/hex_coord.gd")
const HexGridMath = preload("res://src/core/hex/hex_grid_math.gd")
const HexOrganismRenderer = preload("res://src/rendering/hex_organism_renderer.gd")
const HexRenderConfig = preload("res://src/rendering/hex_render_config.gd")
const OrganismSnapshotBuilder = preload("res://src/runtime/organism_snapshot_builder.gd")
const ParticleEffectAdapter = preload("res://src/rendering/particle_effect_adapter.gd")
const PerfProbe = preload("res://src/debug/perf_probe.gd")
const SimulationService = preload("res://src/sim/simulation_service.gd")
const StarterBacteriumFactory = preload("res://src/sim/body/starter_bacterium_factory.gd")
const WorldEnvironmentAdapter = preload("res://src/rendering/world_environment_adapter.gd")

const ORGANISM_ID = 1

@export var seed: int = 1
@export var render_config: HexRenderConfig
@export var energy_config: EnergyConfig
@export_range(60.0, 1200.0, 10.0) var camera_pan_speed: float = 420.0
@export_range(0.02, 0.40, 0.01) var camera_zoom_step: float = 0.12
@export_range(0.20, 1.00, 0.01) var camera_min_zoom: float = 0.45
@export_range(1.00, 4.00, 0.05) var camera_max_zoom: float = 2.25
@export_range(0.20, 2.00, 0.01) var camera_default_zoom: float = 0.72
@export var use_stress_body: bool = false
@export_range(7, 250, 1) var stress_cell_count: int = 100

var service: SimulationService
var catalog: CellFunctionCatalog
var renderer: HexOrganismRenderer
var lab_camera: Camera2D
var world_environment: WorldEnvironment
var ambient_particles: Node
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

	_create_camera()
	world_environment = WorldEnvironmentAdapter.ensure_single_instance(self)
	ambient_particles = ParticleEffectAdapter.setup_world_ambient(renderer)

	_create_ui()
	_apply_render_mode()
	_rebuild()


func _process(delta: float) -> void:
	_process_camera(delta)
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


func _process_camera(delta: float) -> void:
	if lab_camera == null:
		return
	var axis = Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		axis.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		axis.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		axis.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		axis.y += 1.0
	if axis == Vector2.ZERO:
		return
	var zoom_factor = maxf(0.05, lab_camera.zoom.x)
	lab_camera.position += axis.normalized() * camera_pan_speed * delta / zoom_factor


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				_adjust_camera_zoom(1.0)
				get_viewport().set_input_as_handled()
			MOUSE_BUTTON_WHEEL_DOWN:
				_adjust_camera_zoom(-1.0)
				get_viewport().set_input_as_handled()
		return

	if not (event is InputEventKey) or not event.pressed or event.echo:
		return

	match event.keycode:
		KEY_C:
			reset_camera_view()
		KEY_N:
			seed += 1
			_rebuild()
		KEY_B:
			seed = max(1, seed - 1)
			_rebuild()
		KEY_R:
			seed = int(Time.get_unix_time_from_system()) % 100000
			_rebuild()
		KEY_G:
			render_config.render_mode = "debug" if render_config.render_mode == "beauty" else "beauty"
			_apply_render_mode()
			_update_label()
		KEY_F:
			render_config.flow_enabled = not render_config.flow_enabled
			renderer.queue_redraw()
			_update_label()
		KEY_F3:
			DebugMenuAdapter.toggle(self)


func _create_camera() -> void:
	lab_camera = Camera2D.new()
	lab_camera.name = "LabCamera2D"
	lab_camera.enabled = true
	lab_camera.position_smoothing_enabled = true
	lab_camera.position_smoothing_speed = 9.0
	add_child(lab_camera)
	reset_camera_view()
	lab_camera.make_current()


func reset_camera_view() -> void:
	if lab_camera == null:
		return
	lab_camera.position = _default_camera_position()
	var default_zoom = clampf(camera_default_zoom, camera_min_zoom, camera_max_zoom)
	lab_camera.zoom = Vector2.ONE * default_zoom
	lab_camera.reset_smoothing()


func _adjust_camera_zoom(direction: float) -> void:
	if lab_camera == null:
		return
	var zoom_factor = 1.0 + camera_zoom_step * direction
	var next_zoom = clampf(lab_camera.zoom.x * zoom_factor, camera_min_zoom, camera_max_zoom)
	lab_camera.zoom = Vector2.ONE * next_zoom


func _default_camera_position() -> Vector2:
	return get_viewport_rect().size * 0.5


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
	var body = _build_stress_body() if use_stress_body else StarterBacteriumFactory.new().build(service, ORGANISM_ID, seed)
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
	info_label.text = "Baktorium Slice 2\nSeed: %d  Mode: %s%s\nCells: %d\nEnergy: %.1f/%.1f%s\nProd: %.1f  Maint: %.1f  Net: %.1f  Tick: %d\nBody: %dus Energy: %dus Snapshot: %dus\nG Beauty/Debug  F Flow:%s  N/B/R Seed  F3 Menu\nWASD/Arrows Pan  Wheel Zoom  C Camera" % [
		seed,
		render_config.render_mode,
		" stress" if use_stress_body else "",
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


func _apply_render_mode() -> void:
	if render_config == null:
		return
	var is_debug = render_config.render_mode == "debug"
	render_config.show_debug_overlay = is_debug
	render_config.show_coordinates = is_debug
	render_config.show_function_ids = is_debug
	WorldEnvironmentAdapter.set_glow_enabled(world_environment, not is_debug)
	ParticleEffectAdapter.set_enabled(ambient_particles, render_config.ambient_particles_enabled and not is_debug)
	if renderer != null:
		renderer.set_render_config(render_config)


func _build_stress_body():
	service.create_organism(ORGANISM_ID, seed)
	var coords = _build_connected_stress_coords(stress_cell_count)
	for index in coords.size():
		service.place_cell(ORGANISM_ID, coords[index], _stress_function_id(index), seed + index * 97)
	return service.get_body(ORGANISM_ID)


func _build_connected_stress_coords(count: int) -> Array:
	var target_count = maxi(1, count)
	var coords: Array = [HexCoord.new(0, 0)]
	var seen = {coords[0].to_key(): true}
	var cursor = 0
	while coords.size() < target_count and cursor < coords.size():
		for neighbor_coord in HexGridMath.neighbors(coords[cursor]):
			var key = neighbor_coord.to_key()
			if seen.has(key):
				continue
			seen[key] = true
			coords.append(neighbor_coord)
			if coords.size() >= target_count:
				break
		cursor += 1
	return coords


func _stress_function_id(index: int) -> StringName:
	if index == 0:
		return &"energy_core"
	if index % 11 == 0:
		return &"reproduction"
	if index % 3 == 0:
		return &"photosynthesis"
	return &"wall"
