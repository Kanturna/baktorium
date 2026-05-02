extends SceneTree

const COLS := 5
const ROWS := 2
const FRAME_COUNT := COLS * ROWS
const ALPHA_THRESHOLD := 0.003
const DRIFT_GATE_PX := 1.0
const SAFE_MARGIN_PX := 8

const ITEMS := [
	{
		"name": "energy_core",
		"source": "res://png/energy_core/energy_core frames 10.png",
		"sheet": "res://assets/textures/cell_functions/energy_core_frames.png",
		"static": "res://assets/textures/cell_functions/energy_core.png",
		"frames": "res://resources/cell_functions/energy_core_frames.tres",
		"ext_id": "1_energy_core_frames",
	},
	{
		"name": "photosynthesis",
		"source": "res://png/photosynthesis 3/photosynthesis 3 frames 10.png",
		"sheet": "res://assets/textures/cell_functions/photosynthesis_frames.png",
		"static": "res://assets/textures/cell_functions/photosynthesis.png",
		"frames": "res://resources/cell_functions/photosynthesis_frames.tres",
		"ext_id": "1_photo_frames",
	},
	{
		"name": "reproduction",
		"source": "res://png/reproduction 3/reproduction 3 frames 10.png",
		"sheet": "res://assets/textures/cell_functions/reproduction_frames.png",
		"static": "res://assets/textures/cell_functions/reproduction.png",
		"frames": "res://resources/cell_functions/reproduction_frames.tres",
		"ext_id": "1_reproduction_frames",
	},
	{
		"name": "wall_outer",
		"source": "res://png/outer_wall_membrane/outer_wall_membrane frames 10.png",
		"sheet": "res://assets/textures/cell_functions/wall_outer_frames.png",
		"static": "res://assets/textures/cell_functions/wall_outer.png",
		"frames": "res://resources/cell_functions/wall_outer_frames.tres",
		"ext_id": "1_wall_outer_frames",
	},
	{
		"name": "wall_inner",
		"source": "res://png/inner_wall_membrane 2/inner_wall_membrane 2 frames 10.png",
		"sheet": "res://assets/textures/cell_functions/wall_inner_frames.png",
		"static": "res://assets/textures/cell_functions/wall_inner.png",
		"frames": "res://resources/cell_functions/wall_inner_frames.tres",
		"ext_id": "1_wall_inner_frames",
	},
]


func _initialize() -> void:
	var failures: Array[String] = []
	var reports: Array[Dictionary] = []
	_ensure_output_dirs()
	for item in ITEMS:
		var report = _normalize_item(item)
		reports.append(report)
		if not report.get("ok", false):
			failures.append("%s: %s" % [item["name"], report.get("error", "unknown failure")])
		else:
			print("%s: tile=%dx%d drift=%.2fpx strategy=%s" % [
				item["name"],
				report["tile_w"],
				report["tile_h"],
				report["drift"],
				report["strategy"],
			])
	_report_cross_function_tile_diff(reports)
	if failures.is_empty():
		print("Cell spritesheet normalization: OK")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _ensure_output_dirs() -> void:
	for path in [
		"res://assets/textures/cell_functions",
		"res://resources/cell_functions",
	]:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))


func _normalize_item(item: Dictionary) -> Dictionary:
	var source = Image.new()
	var load_error = source.load(ProjectSettings.globalize_path(item["source"]))
	if load_error != OK:
		return {"ok": false, "error": "could not load source %s" % item["source"]}
	if source.get_width() < COLS or source.get_height() < ROWS:
		return {"ok": false, "error": "source too small"}

	var source_tile = Vector2i(floori(float(source.get_width()) / float(COLS)), floori(float(source.get_height()) / float(ROWS)))
	var bounds = _collect_bounds(source, source_tile)
	if bounds.is_empty():
		return {"ok": false, "error": "no visible pixels above alpha threshold"}

	var content_size = _target_content_size(bounds)
	var target_tile = _target_tile_size(source_tile, bounds)
	var target_center = Vector2(target_tile.x, target_tile.y) * 0.5
	var sheet = _build_sheet(source, source_tile, target_tile, bounds, target_center, content_size)
	var drift = _measure_sheet_drift(sheet, target_tile)
	var strategy = "tile_center_scaled"
	if drift > DRIFT_GATE_PX:
		target_center = Vector2(floorf(float(target_tile.x) * 0.5), floorf(float(target_tile.y) * 0.5))
		sheet = _build_sheet(source, source_tile, target_tile, bounds, target_center, content_size)
		drift = _measure_sheet_drift(sheet, target_tile)
		strategy = "integer_tile_center_scaled"

	if drift > DRIFT_GATE_PX:
		return {
			"ok": false,
			"error": "frame-center drift %.2fpx exceeds %.2fpx" % [drift, DRIFT_GATE_PX],
			"tile_w": target_tile.x,
			"tile_h": target_tile.y,
			"drift": drift,
			"strategy": strategy,
		}

	var save_error = sheet.save_png(ProjectSettings.globalize_path(item["sheet"]))
	if save_error != OK:
		return {"ok": false, "error": "could not save normalized sheet %s" % item["sheet"]}
	var static_image = Image.create(target_tile.x, target_tile.y, false, Image.FORMAT_RGBA8)
	static_image.fill(Color(0, 0, 0, 0))
	static_image.blit_rect(sheet, Rect2i(Vector2i.ZERO, target_tile), Vector2i.ZERO)
	save_error = static_image.save_png(ProjectSettings.globalize_path(item["static"]))
	if save_error != OK:
		return {"ok": false, "error": "could not save static texture %s" % item["static"]}
	var write_error = _write_sprite_frames(item["frames"], item["sheet"], item["ext_id"], target_tile)
	if write_error != OK:
		return {"ok": false, "error": "could not write SpriteFrames %s" % item["frames"]}

	return {
		"ok": true,
		"name": item["name"],
		"tile_w": target_tile.x,
		"tile_h": target_tile.y,
		"drift": drift,
		"strategy": strategy,
	}


func _collect_bounds(source: Image, source_tile: Vector2i) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	for frame_index in FRAME_COUNT:
		var col = frame_index % COLS
		var row = frame_index / COLS
		var origin = Vector2i(col * source_tile.x, row * source_tile.y)
		var min_x = source_tile.x
		var min_y = source_tile.y
		var max_x = -1
		var max_y = -1
		for y in source_tile.y:
			for x in source_tile.x:
				if source.get_pixel(origin.x + x, origin.y + y).a <= ALPHA_THRESHOLD:
					continue
				min_x = mini(min_x, x)
				min_y = mini(min_y, y)
				max_x = maxi(max_x, x)
				max_y = maxi(max_y, y)
		if max_x < min_x or max_y < min_y:
			continue
		results.append({
			"x": min_x,
			"y": min_y,
			"w": max_x - min_x + 1,
			"h": max_y - min_y + 1,
			"center": Vector2((min_x + max_x) * 0.5, (min_y + max_y) * 0.5),
			"frame_index": frame_index,
		})
	return results


func _target_tile_size(source_tile: Vector2i, bounds: Array[Dictionary]) -> Vector2i:
	var content_size = _target_content_size(bounds)
	return Vector2i(
		_even(content_size.x + SAFE_MARGIN_PX * 2),
		_even(content_size.y + SAFE_MARGIN_PX * 2)
	)


func _target_content_size(bounds: Array[Dictionary]) -> Vector2i:
	var max_w = 1
	var max_h = 1
	for item in bounds:
		max_w = maxi(max_w, int(item["w"]))
		max_h = maxi(max_h, int(item["h"]))
	return Vector2i(max_w, max_h)


func _even(value: int) -> int:
	return value if value % 2 == 0 else value + 1


func _build_sheet(source: Image, source_tile: Vector2i, target_tile: Vector2i, bounds: Array[Dictionary], target_center: Vector2, content_size: Vector2i) -> Image:
	var target = Image.create(target_tile.x * COLS, target_tile.y * ROWS, false, Image.FORMAT_RGBA8)
	target.fill(Color(0, 0, 0, 0))
	for item in bounds:
		var frame_index = int(item["frame_index"])
		var col = frame_index % COLS
		var row = frame_index / COLS
		var src_rect = Rect2i(
			col * source_tile.x + int(item["x"]),
			row * source_tile.y + int(item["y"]),
			int(item["w"]),
			int(item["h"])
		)
		var frame = source.get_region(src_rect)
		if frame.get_size() != content_size:
			frame.resize(content_size.x, content_size.y, Image.INTERPOLATE_LANCZOS)
		var dst = Vector2i(
			col * target_tile.x + roundi(target_center.x - float(content_size.x) * 0.5),
			row * target_tile.y + roundi(target_center.y - float(content_size.y) * 0.5)
		)
		target.blit_rect(frame, Rect2i(Vector2i.ZERO, content_size), dst)
	return target


func _measure_sheet_drift(sheet: Image, tile: Vector2i) -> float:
	var centers: Array[Vector2] = []
	var bounds = _collect_bounds(sheet, tile)
	for item in bounds:
		centers.append(item["center"])
	if centers.size() < 2:
		return 0.0
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


func _median_source_center(bounds: Array[Dictionary]) -> Vector2:
	var xs: Array[float] = []
	var ys: Array[float] = []
	for item in bounds:
		var center = item["center"] as Vector2
		xs.append(center.x)
		ys.append(center.y)
	xs.sort()
	ys.sort()
	var middle = xs.size() / 2
	if xs.size() % 2 == 1:
		return Vector2(xs[middle], ys[middle])
	return Vector2((xs[middle - 1] + xs[middle]) * 0.5, (ys[middle - 1] + ys[middle]) * 0.5)


func _write_sprite_frames(resource_path: String, texture_path: String, ext_id: String, tile: Vector2i) -> Error:
	var text = "[gd_resource type=\"SpriteFrames\" load_steps=12 format=3]\n\n"
	text += "[ext_resource type=\"Texture2D\" path=\"%s\" id=\"%s\"]\n\n" % [texture_path, ext_id]
	for frame_index in FRAME_COUNT:
		var col = frame_index % COLS
		var row = frame_index / COLS
		text += "[sub_resource type=\"AtlasTexture\" id=\"AtlasTexture_%d\"]\n" % frame_index
		text += "atlas = ExtResource(\"%s\")\n" % ext_id
		text += "region = Rect2(%d, %d, %d, %d)\n\n" % [
			col * tile.x,
			row * tile.y,
			tile.x,
			tile.y,
		]
	text += "[resource]\n"
	text += "animations = [{\n"
	text += "\"frames\": ["
	for frame_index in FRAME_COUNT:
		if frame_index > 0:
			text += ", "
		text += "{\n\"duration\": 1.0,\n\"texture\": SubResource(\"AtlasTexture_%d\")\n}" % frame_index
	text += "\n],\n"
	text += "\"loop\": true,\n"
	text += "\"name\": &\"default\",\n"
	text += "\"speed\": 1.0\n"
	text += "}]\n"
	var file = FileAccess.open(ProjectSettings.globalize_path(resource_path), FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(text)
	file.close()
	return OK


func _report_cross_function_tile_diff(reports: Array[Dictionary]) -> void:
	var min_dim = INF
	var max_dim = 0.0
	for report in reports:
		if not report.get("ok", false):
			continue
		var largest = float(maxi(int(report["tile_w"]), int(report["tile_h"])))
		min_dim = minf(min_dim, largest)
		max_dim = maxf(max_dim, largest)
	if min_dim == INF or min_dim <= 0.0:
		return
	var diff = (max_dim / min_dim) - 1.0
	if diff > 0.05:
		print("Cross-function tile dimension diff %.2f%% exceeds 5%%; keep manual sign-off finding open." % (diff * 100.0))
