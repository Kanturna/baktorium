extends SceneTree

const CellFunctionCatalog = preload("res://src/sim/catalog/cell_function_catalog.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	_validate_assets_exist(failures)
	_validate_sprite_frames(failures)
	_validate_catalog_visual_schema(failures)
	_validate_source_boundaries(failures)
	_validate_docs(failures)
	_finish("Polish A1 assets validation", failures)


func _validate_assets_exist(failures: Array[String]) -> void:
	for path in [
		"res://assets/textures/cell_functions/energy_core.png",
		"res://assets/textures/cell_functions/energy_core_frames.png",
		"res://assets/textures/cell_functions/photosynthesis.png",
		"res://assets/textures/cell_functions/photosynthesis_frames.png",
		"res://assets/textures/cell_functions/reproduction.png",
		"res://assets/textures/cell_functions/reproduction_frames.png",
		"res://assets/textures/cell_functions/wall_outer.png",
		"res://assets/textures/cell_functions/wall_outer_frames.png",
		"res://assets/textures/cell_functions/wall_inner.png",
		"res://assets/textures/cell_functions/wall_inner_frames.png",
		"res://assets/textures/cell_functions/_alternates/energy_core_2.png",
		"res://assets/textures/cell_functions/_alternates/inner_outer_wall_membrane.png",
	]:
		if not FileAccess.file_exists(path):
			failures.append("Missing asset %s." % path)


func _validate_sprite_frames(failures: Array[String]) -> void:
	for path in [
		"res://resources/cell_functions/energy_core_frames.tres",
		"res://resources/cell_functions/photosynthesis_frames.tres",
		"res://resources/cell_functions/reproduction_frames.tres",
		"res://resources/cell_functions/wall_outer_frames.tres",
		"res://resources/cell_functions/wall_inner_frames.tres",
	]:
		var frames = load(path) as SpriteFrames
		if frames == null:
			failures.append("SpriteFrames failed to load: %s." % path)
			continue
		if not frames.has_animation(&"default"):
			failures.append("SpriteFrames missing default animation: %s." % path)
		elif frames.get_frame_count(&"default") != 10:
			failures.append("SpriteFrames should contain 10 frames: %s." % path)
		for index in frames.get_frame_count(&"default"):
			var texture = frames.get_frame_texture(&"default", index)
			if texture == null:
				failures.append("SpriteFrames frame %d has no texture: %s." % [index, path])


func _validate_catalog_visual_schema(failures: Array[String]) -> void:
	var catalog = CellFunctionCatalog.default_catalog()
	for id in [&"energy_core", &"photosynthesis", &"reproduction", &"wall"]:
		var definition = catalog.get_definition(id)
		if definition == null:
			failures.append("Missing catalog definition %s." % String(id))
			continue
		if definition.outer_sprite_texture == null:
			failures.append("Definition %s missing outer sprite texture." % String(id))
		if definition.outer_sprite_frames == null:
			failures.append("Definition %s missing outer sprite frames." % String(id))
		if id == &"wall":
			if definition.inner_sprite_texture == null:
				failures.append("Wall definition missing inner sprite texture.")
			if definition.inner_sprite_frames == null:
				failures.append("Wall definition missing inner sprite frames.")


func _validate_source_boundaries(failures: Array[String]) -> void:
	for path in [
		"res://src/sim/body/organism_body.gd",
		"res://src/sim/body/starter_bacterium_factory.gd",
		"res://src/sim/energy/energy_system.gd",
		"res://src/sim/energy/organism_energy_state.gd",
		"res://src/sim/simulation_service.gd",
		"res://src/genetics/genome.gd",
		"res://src/runtime/organism_snapshot_builder.gd",
	]:
		var source = FileAccess.get_file_as_string(path)
		if source.contains("res://assets/") or source.contains("kenney_particle_pack"):
			failures.append("%s should not import visual assets directly." % path)


func _validate_docs(failures: Array[String]) -> void:
	var decisions = FileAccess.get_file_as_string("res://docs/DECISIONS.md")
	if not decisions.contains("ADR-010: Simulation Truth vs Visual Truth"):
		failures.append("DECISIONS.md missing ADR-010.")
	if not decisions.contains("ADR-011: Custom Cell Sprites With Animation"):
		failures.append("DECISIONS.md missing ADR-011.")
	if not decisions.contains("Sim systems do not read these visual fields"):
		failures.append("DECISIONS.md missing visual-field simulation guardrail.")


func _finish(label: String, failures: Array[String]) -> void:
	if failures.is_empty():
		print("%s: OK" % label)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
