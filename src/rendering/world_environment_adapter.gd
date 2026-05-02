class_name WorldEnvironmentAdapter
extends RefCounted

const ENVIRONMENT_PATH = "res://resources/render/starter_lab_environment.tres"
const WORLD_ENVIRONMENT_GROUP = "world_environment"


static func ensure_single_instance(parent: Node) -> WorldEnvironment:
	if parent == null:
		return null
	if parent.is_inside_tree():
		var existing = parent.get_tree().get_first_node_in_group(WORLD_ENVIRONMENT_GROUP)
		if existing is WorldEnvironment:
			return existing
	for child in parent.get_children():
		if child is WorldEnvironment and child.is_in_group(WORLD_ENVIRONMENT_GROUP):
			return child

	var env_node = WorldEnvironment.new()
	env_node.name = "StarterLabWorldEnvironment"
	env_node.add_to_group(WORLD_ENVIRONMENT_GROUP)
	env_node.environment = load(ENVIRONMENT_PATH)
	parent.add_child(env_node)
	return env_node


static func set_glow_enabled(env_node: WorldEnvironment, enabled: bool) -> void:
	if env_node == null or env_node.environment == null:
		return
	env_node.environment.glow_enabled = enabled
