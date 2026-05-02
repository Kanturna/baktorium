extends SceneTree

const HexRenderConfig = preload("res://src/rendering/hex_render_config.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	_validate_lab_camera_source(failures)
	_validate_render_defaults(failures)
	_validate_docs(failures)
	_finish("Slice 2 camera validation", failures)


func _validate_lab_camera_source(failures: Array[String]) -> void:
	var source = FileAccess.get_file_as_string("res://src/lab/starter_bacterium_lab.gd")
	for required in [
		"var lab_camera: Camera2D",
		"camera_pan_speed",
		"camera_zoom_step",
		"camera_min_zoom",
		"camera_max_zoom",
		"camera_default_zoom",
		"func _process_camera",
		"func reset_camera_view",
		"func _adjust_camera_zoom",
		"MOUSE_BUTTON_WHEEL_UP",
		"MOUSE_BUTTON_WHEEL_DOWN",
		"KEY_W",
		"KEY_A",
		"KEY_S",
		"KEY_D",
		"KEY_C",
	]:
		if not source.contains(required):
			failures.append("Lab camera source missing %s." % required)
	if source.contains("KEY_D:\n\t\t\trender_config.show_debug_overlay"):
		failures.append("Debug overlay must not use D because D is camera pan.")
	if not source.contains("KEY_G"):
		failures.append("Debug overlay should move to G.")
	if source.contains("PhantomCamera") or source.contains("phantom_camera"):
		failures.append("Slice 2 camera controls should use built-in Camera2D, not Phantom Camera.")
	if not source.contains("CanvasLayer"):
		failures.append("HUD should stay in CanvasLayer so camera zoom does not scale HUD text.")
	if source.contains("renderer.queue_redraw()") and source.contains("_process_camera"):
		var camera_process = source.substr(source.find("func _process_camera"), source.find("func _unhandled_input") - source.find("func _process_camera"))
		if camera_process.contains("queue_redraw") or camera_process.contains("_refresh_snapshot"):
			failures.append("Camera pan must not rebuild snapshots or force renderer redraws.")


func _validate_render_defaults(failures: Array[String]) -> void:
	var config = load("res://resources/render/starter_bacterium_render_config.tres") as HexRenderConfig
	if config == null:
		failures.append("Starter render config missing.")
		return
	if config.show_debug_overlay:
		failures.append("Debug overlay should default to false for camera/visual calibration.")


func _validate_docs(failures: Array[String]) -> void:
	var decisions = FileAccess.get_file_as_string("res://docs/DECISIONS.md")
	if not decisions.contains("ADR-009: Lab Camera Uses Built-In Camera2D"):
		failures.append("DECISIONS.md missing ADR-009 for lab camera choice.")
	var next_steps = FileAccess.get_file_as_string("res://docs/NEXT_STEPS.md")
	for required in ["WASD", "Mouse wheel", "C", "G"]:
		if not next_steps.contains(required):
			failures.append("NEXT_STEPS.md missing camera/manual gate text for %s." % required)


func _finish(label: String, failures: Array[String]) -> void:
	if failures.is_empty():
		print("%s: OK" % label)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
