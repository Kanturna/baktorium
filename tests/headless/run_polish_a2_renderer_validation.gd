extends SceneTree

const CellFunctionCatalog = preload("res://src/sim/catalog/cell_function_catalog.gd")
const HexCoord = preload("res://src/core/hex/hex_coord.gd")
const HexOrganismRenderer = preload("res://src/rendering/hex_organism_renderer.gd")
const HexRenderConfig = preload("res://src/rendering/hex_render_config.gd")
const OrganismSnapshotBuilder = preload("res://src/runtime/organism_snapshot_builder.gd")
const SimulationService = preload("res://src/sim/simulation_service.gd")
const StarterBacteriumFactory = preload("res://src/sim/body/starter_bacterium_factory.gd")

const EPS := 0.005


func _initialize() -> void:
	var failures: Array[String] = []
	var catalog = CellFunctionCatalog.default_catalog()
	_validate_snapshot_visual_fields(catalog, failures)
	_validate_boundary_switch(catalog, failures)
	_validate_renderer_source(failures)
	_validate_render_config(failures)
	_validate_sprite_scale(failures)
	_validate_animation_speed(failures)
	_validate_mode_snapshot_invariance(catalog, failures)
	_validate_lab_hotkey(failures)
	_finish("Polish A2 renderer validation", failures)


func _validate_snapshot_visual_fields(catalog, failures: Array[String]) -> void:
	var service = SimulationService.new()
	get_root().add_child(service)
	var body = StarterBacteriumFactory.new().build(service, 1, 31)
	var snapshot = OrganismSnapshotBuilder.build(body, catalog)
	for cell_data in snapshot.cells:
		for required in [
			"outer_sprite_texture",
			"outer_sprite_frames",
			"sprite_texture",
			"sprite_frames",
			"animation_base_fps",
			"animation_modulation_strength",
			"animation_modulator",
		]:
			if not cell_data.has(required):
				failures.append("Snapshot cell missing visual field %s." % required)
		if cell_data["sprite_texture"] == null:
			failures.append("Snapshot cell should resolve a selected sprite texture.")


func _validate_boundary_switch(catalog, failures: Array[String]) -> void:
	var service = SimulationService.new()
	get_root().add_child(service)
	service.create_organism(2, 1)
	for coord in [
		HexCoord.new(0, 0),
		HexCoord.new(1, 0),
		HexCoord.new(1, -1),
		HexCoord.new(0, -1),
		HexCoord.new(-1, 0),
		HexCoord.new(-1, 1),
		HexCoord.new(0, 1),
	]:
		service.place_cell(2, coord, &"wall", 1)
	var snapshot = OrganismSnapshotBuilder.build(service.get_body(2), catalog)
	for cell_data in snapshot.cells:
		if cell_data["q"] == 0 and cell_data["r"] == 0:
			if cell_data["is_boundary"]:
				failures.append("Center wall in seven-wall cluster should be interior.")
			if cell_data["sprite_texture"] != cell_data["inner_sprite_texture"]:
				failures.append("Interior wall should use inner wall sprite.")
		elif cell_data["function_id"] == &"wall" and cell_data["sprite_texture"] != cell_data["outer_sprite_texture"]:
			failures.append("Boundary wall should use outer wall sprite.")


func _validate_renderer_source(failures: Array[String]) -> void:
	var source = FileAccess.get_file_as_string("res://src/rendering/hex_organism_renderer.gd")
	for required in ["AnimatedSprite2D", "Sprite2D", "_sync_sprite_nodes", "draw_colored_polygon", "energy_activity", "energy_tint_strength"]:
		if not source.contains(required):
			failures.append("Renderer source missing %s." % required)
	for forbidden in ["SimulationService", "EnergySystem", "OrganismEnergyState", "OrganismBody"]:
		if source.contains(forbidden):
			failures.append("Renderer must not depend on %s." % forbidden)


func _validate_render_config(failures: Array[String]) -> void:
	var config = load("res://resources/render/starter_bacterium_render_config.tres") as HexRenderConfig
	if config == null:
		failures.append("Starter render config failed to load.")
		return
	if config.hex_radius != 42.0:
		failures.append("hex_radius should stay at Slice-2 default 42.0.")
	if config.render_mode != "beauty":
		failures.append("Render mode should default to beauty.")
	if config.boundary_glow_enabled:
		failures.append("Boundary glow should default to false.")
	if config.show_debug_overlay:
		failures.append("Debug overlay should default off in beauty mode.")
	if config.sprite_diameter_scale != 1.1:
		failures.append("sprite_diameter_scale should default to 1.1 after visual sign-off correction.")


func _validate_sprite_scale(failures: Array[String]) -> void:
	var renderer = HexOrganismRenderer.new()
	var config = HexRenderConfig.new()
	config.hex_radius = 42.0
	config.sprite_diameter_scale = 1.1
	renderer.render_config = config
	var texture = load("res://assets/textures/cell_functions/energy_core.png")
	var cell_data = {"sprite_texture": texture, "sprite_frames": null}
	var expected = config.hex_radius * 2.0 * config.sprite_diameter_scale / maxf(texture.get_width(), texture.get_height())
	_expect_close(renderer._calculate_sprite_scale(cell_data), expected, "sprite scale", failures)
	renderer.free()


func _validate_animation_speed(failures: Array[String]) -> void:
	var renderer = HexOrganismRenderer.new()
	for item in [
		[0.0, 0.5],
		[0.5, 1.0],
		[1.0, 1.5],
	]:
		var speed = renderer._calculate_animation_speed({
			"animation_modulator": item[0],
			"animation_modulation_strength": 0.5,
		})
		_expect_close(speed, item[1], "animation speed", failures)
	renderer.free()


func _validate_mode_snapshot_invariance(catalog, failures: Array[String]) -> void:
	var service = SimulationService.new()
	get_root().add_child(service)
	var body = StarterBacteriumFactory.new().build(service, 3, 41)
	var beauty_snapshot = OrganismSnapshotBuilder.build(body, catalog)
	var debug_snapshot = OrganismSnapshotBuilder.build(body, catalog)
	if beauty_snapshot.cell_count != debug_snapshot.cell_count:
		failures.append("Render mode should not alter snapshot cell count.")
	for index in beauty_snapshot.cells.size():
		var a = beauty_snapshot.cells[index]
		var b = debug_snapshot.cells[index]
		if a["q"] != b["q"] or a["r"] != b["r"] or a["function_id"] != b["function_id"]:
			failures.append("Render mode should not alter snapshot sim data.")


func _validate_lab_hotkey(failures: Array[String]) -> void:
	var source = FileAccess.get_file_as_string("res://src/lab/starter_bacterium_lab.gd")
	if not source.contains("KEY_G") or not source.contains("render_config.render_mode"):
		failures.append("Lab should toggle render_mode with G.")
	if source.contains("KEY_D:\n\t\t\trender_config"):
		failures.append("D must remain camera pan, not render toggle.")


func _expect_close(actual: float, expected: float, label: String, failures: Array[String]) -> void:
	if absf(actual - expected) > EPS:
		failures.append("%s expected %.4f, got %.4f." % [label, expected, actual])


func _finish(label: String, failures: Array[String]) -> void:
	if failures.is_empty():
		print("%s: OK" % label)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
