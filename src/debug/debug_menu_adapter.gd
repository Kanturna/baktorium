class_name DebugMenuAdapter
extends RefCounted


static func toggle(root: Node) -> void:
	if root == null:
		return
	var debug_menu = root.get_node_or_null("/root/DebugMenu")
	if debug_menu == null:
		return
	var current = int(debug_menu.get("style"))
	debug_menu.set("style", (current + 1) % 3)

