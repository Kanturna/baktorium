extends SceneTree

const DebugMenuAdapter = preload("res://src/debug/debug_menu_adapter.gd")
const HexOutlineDrawer = preload("res://src/rendering/hex_outline_drawer.gd")
const HexRenderConfig = preload("res://src/rendering/hex_render_config.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	_validate_plugins(failures)
	_validate_render_config(failures)
	_validate_adapters(failures)
	_validate_plugin_isolation(failures)
	_finish("Slice 1D plugin validation", failures)


func _validate_plugins(failures: Array[String]) -> void:
	var project = FileAccess.get_file_as_string("res://project.godot")
	if not project.contains("res://addons/antialiased_line2d/plugin.cfg"):
		failures.append("Antialiased Line2D plugin is not enabled in project.godot.")
	if not project.contains("res://addons/debug_menu/plugin.cfg"):
		failures.append("Debug Menu plugin is not enabled in project.godot.")
	if not FileAccess.file_exists("res://addons/antialiased_line2d/plugin.cfg"):
		failures.append("Antialiased Line2D plugin.cfg missing.")
	if not FileAccess.file_exists("res://addons/debug_menu/plugin.cfg"):
		failures.append("Debug Menu plugin.cfg missing.")


func _validate_render_config(failures: Array[String]) -> void:
	var config = load("res://resources/render/starter_bacterium_render_config.tres") as HexRenderConfig
	if config == null:
		failures.append("Render config resource missing.")
		return
	if config.flow_enabled:
		failures.append("flow_enabled must default to false.")


func _validate_adapters(failures: Array[String]) -> void:
	if not HexOutlineDrawer.new().has_method("plugin_available"):
		failures.append("HexOutlineDrawer adapter missing plugin_available().")
	if not DebugMenuAdapter.new().has_method("toggle"):
		failures.append("DebugMenuAdapter missing toggle().")


func _validate_plugin_isolation(failures: Array[String]) -> void:
	var files: Array[String] = []
	for path in ["res://src/sim", "res://src/genetics", "res://src/runtime"]:
		_collect_gd_files(path, files)
	for file_path in files:
		var source = FileAccess.get_file_as_string(file_path)
		if source.contains("addons/antialiased_line2d") or source.contains("addons/debug_menu"):
			failures.append("Plugin path leaked into non-render/debug layer: %s" % file_path)
		if source.contains("AntialiasedLine2D") or source.contains("DebugMenu"):
			failures.append("Plugin class leaked into non-render/debug layer: %s" % file_path)


func _collect_gd_files(path: String, files: Array[String]) -> void:
	var dir = DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var entry = dir.get_next()
	while entry != "":
		if entry.begins_with("."):
			entry = dir.get_next()
			continue
		var child_path = "%s/%s" % [path, entry]
		if dir.current_is_dir():
			_collect_gd_files(child_path, files)
		elif entry.ends_with(".gd"):
			files.append(child_path)
		entry = dir.get_next()


func _finish(label: String, failures: Array[String]) -> void:
	if failures.is_empty():
		print("%s: OK" % label)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
