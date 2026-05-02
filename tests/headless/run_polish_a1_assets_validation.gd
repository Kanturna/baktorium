extends SceneTree

const CellFunctionCatalog = preload("res://src/sim/catalog/cell_function_catalog.gd")
const HexRenderConfig = preload("res://src/rendering/hex_render_config.gd")

const COLS := 5
const ROWS := 2
const FRAME_COUNT := COLS * ROWS
const ALPHA_THRESHOLD := 0.003
const DRIFT_GATE_PX := 1.0
const SIZE_DRIFT_GATE_PX := 1.0

const ACTIVE_TEXTURES := [
	"res://assets/textures/cell_functions/energy_core.png",
	"res://assets/textures/cell_functions/photosynthesis.png",
	"res://assets/textures/cell_functions/reproduction.png",
	"res://assets/textures/cell_functions/wall_outer.png",
	"res://assets/textures/cell_functions/wall_inner.png",
]

const ACTIVE_FRAME_SHEETS := [
	"res://assets/textures/cell_functions/energy_core_frames.png",
	"res://assets/textures/cell_functions/photosynthesis_frames.png",
	"res://assets/textures/cell_functions/reproduction_frames.png",
	"res://assets/textures/cell_functions/wall_outer_frames.png",
	"res://assets/textures/cell_functions/wall_inner_frames.png",
]


func _initialize() -> void:
	var failures: Array[String] = []
	_validate_assets_exist(failures)
	_validate_transparent_derived_assets(failures)
	_validate_frame_center_drift(failures)
	_validate_mipmaps(failures)
	_validate_sprite_frames(failures)
	_validate_sprite_diameter_sanity(failures)
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


func _validate_transparent_derived_assets(failures: Array[String]) -> void:
	for path in ACTIVE_TEXTURES + ACTIVE_FRAME_SHEETS:
		var image = Image.new()
		if image.load(ProjectSettings.globalize_path(path)) != OK:
			failures.append("Could not load derived texture for alpha validation: %s." % path)
			continue
		var corners = [
			Vector2i(0, 0),
			Vector2i(image.get_width() - 1, 0),
			Vector2i(0, image.get_height() - 1),
			Vector2i(image.get_width() - 1, image.get_height() - 1),
		]
		for corner in corners:
			if image.get_pixel(corner.x, corner.y).a > ALPHA_THRESHOLD:
				failures.append("Derived texture corner should be transparent: %s at %s." % [path, str(corner)])


func _validate_frame_center_drift(failures: Array[String]) -> void:
	for path in ACTIVE_FRAME_SHEETS:
		var image = Image.new()
		if image.load(ProjectSettings.globalize_path(path)) != OK:
			failures.append("Could not load frame sheet for drift validation: %s." % path)
			continue
		if image.get_width() % COLS != 0 or image.get_height() % ROWS != 0:
			failures.append("Normalized sheet should divide exactly into 5x2 frames: %s." % path)
			continue
		var tile = Vector2i(image.get_width() / COLS, image.get_height() / ROWS)
		var centers: Array[Vector2] = []
		var sizes: Array[Vector2] = []
		for frame_index in FRAME_COUNT:
			var col = frame_index % COLS
			var row = frame_index / COLS
			var bounds = _alpha_bounds(image, Vector2i(col * tile.x, row * tile.y), tile)
			if bounds.is_empty():
				failures.append("Frame %d has no visible alpha in %s." % [frame_index, path])
				continue
			centers.append(bounds["center"])
			sizes.append(bounds["size"])
		if centers.size() != FRAME_COUNT:
			continue
		var drift = _center_drift(centers)
		if drift > DRIFT_GATE_PX:
			failures.append("Frame center drift %.2f px exceeds %.2f px in %s." % [drift, DRIFT_GATE_PX, path])
		var size_drift = _center_drift(sizes)
		if size_drift > SIZE_DRIFT_GATE_PX:
			failures.append("Frame visible-size drift %.2f px exceeds %.2f px in %s." % [size_drift, SIZE_DRIFT_GATE_PX, path])


func _alpha_bounds(image: Image, origin: Vector2i, size: Vector2i) -> Dictionary:
	var min_x = size.x
	var min_y = size.y
	var max_x = -1
	var max_y = -1
	for y in size.y:
		for x in size.x:
			if image.get_pixel(origin.x + x, origin.y + y).a <= ALPHA_THRESHOLD:
				continue
			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)
	if max_x < min_x or max_y < min_y:
		return {}
	return {
		"center": Vector2((min_x + max_x) * 0.5, (min_y + max_y) * 0.5),
		"size": Vector2(max_x - min_x + 1, max_y - min_y + 1),
	}


func _center_drift(centers: Array[Vector2]) -> float:
	var min_x = centers[0].x
	var max_x = centers[0].x
	var min_y = centers[0].y
	var max_y = centers[0].y
	for center in centers:
		min_x = minf(min_x, center.x)
		max_x = maxf(max_x, center.x)
		min_y = minf(min_y, center.y)
		max_y = maxf(max_y, center.y)
	return maxf(max_x - min_x, max_y - min_y)


func _validate_mipmaps(failures: Array[String]) -> void:
	for path in ACTIVE_TEXTURES + ACTIVE_FRAME_SHEETS:
		var import_path = "%s.import" % path
		if not FileAccess.file_exists(import_path):
			failures.append("Missing import settings for %s." % path)
			continue
		var source = FileAccess.get_file_as_string(import_path)
		if not source.contains("mipmaps/generate=true"):
			failures.append("Mipmaps should stay enabled for zoomable cell texture: %s." % path)


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
			elif texture is AtlasTexture:
				_validate_integer_region(texture as AtlasTexture, path, index, failures)


func _validate_integer_region(texture: AtlasTexture, path: String, index: int, failures: Array[String]) -> void:
	var region = texture.region
	if not _is_integer_float(region.position.x) or not _is_integer_float(region.position.y):
		failures.append("SpriteFrames frame %d has non-integer region position: %s." % [index, path])
	if not _is_integer_float(region.size.x) or not _is_integer_float(region.size.y):
		failures.append("SpriteFrames frame %d has non-integer region size: %s." % [index, path])


func _validate_sprite_diameter_sanity(failures: Array[String]) -> void:
	var config = load("res://resources/render/starter_bacterium_render_config.tres") as HexRenderConfig
	if config == null:
		failures.append("Starter render config failed to load for sprite diameter sanity.")
		return
	var target_diameter = config.hex_radius * 2.0 * config.sprite_diameter_scale
	var max_reasonable_diameter = config.hex_radius * 2.0 * 1.5
	if target_diameter > max_reasonable_diameter:
		failures.append("Sprite diameter scale is too large for readable neighboring hexes.")
	if config.sprite_diameter_scale > 1.5:
		failures.append("sprite_diameter_scale should stay <= 1.5 before batched/atlas visual retuning.")


func _is_integer_float(value: float) -> bool:
	return absf(value - floorf(value)) <= 0.0001


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
