extends SceneTree

const ParticleEffectAdapter = preload("res://src/rendering/particle_effect_adapter.gd")
const SimulationService = preload("res://src/sim/simulation_service.gd")
const StarterBacteriumLab = preload("res://src/lab/starter_bacterium_lab.gd")
const WorldEnvironmentAdapter = preload("res://src/rendering/world_environment_adapter.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	_validate_world_environment(failures)
	_validate_particles(failures)
	_validate_lab_stress_hook(failures)
	_validate_lab_stress_body_build(failures)
	_finish("Polish A3 environment validation", failures)


func _validate_world_environment(failures: Array[String]) -> void:
	var parent = Node2D.new()
	get_root().add_child(parent)
	var first = WorldEnvironmentAdapter.ensure_single_instance(parent)
	var second = WorldEnvironmentAdapter.ensure_single_instance(parent)
	if first == null:
		failures.append("WorldEnvironmentAdapter should create an environment.")
	if first != second:
		failures.append("WorldEnvironmentAdapter should return the same instance on repeated calls.")
	var count = 0
	for node in parent.get_children():
		if node is WorldEnvironment:
			count += 1
	if count != 1:
		failures.append("Expected exactly one WorldEnvironment node, got %d." % count)
	WorldEnvironmentAdapter.set_glow_enabled(first, false)
	if first != null and first.environment != null and first.environment.glow_enabled:
		failures.append("WorldEnvironmentAdapter should disable glow.")
	WorldEnvironmentAdapter.set_glow_enabled(first, true)
	if first != null and first.environment != null and not first.environment.glow_enabled:
		failures.append("WorldEnvironmentAdapter should enable glow.")
	parent.free()


func _validate_particles(failures: Array[String]) -> void:
	var parent = Node2D.new()
	get_root().add_child(parent)
	var particles = ParticleEffectAdapter.setup_world_ambient(parent)
	if not (particles is GPUParticles2D):
		failures.append("ParticleEffectAdapter should create GPUParticles2D.")
		return
	if particles.amount < 30 or particles.amount > 50:
		failures.append("Ambient particles should stay in the planned 30-50 range.")
	ParticleEffectAdapter.set_enabled(particles, false)
	if particles.visible or particles.emitting:
		failures.append("ParticleEffectAdapter should disable ambient particles.")
	ParticleEffectAdapter.set_enabled(particles, true)
	if not particles.visible or not particles.emitting:
		failures.append("ParticleEffectAdapter should enable ambient particles.")
	parent.free()


func _validate_lab_stress_hook(failures: Array[String]) -> void:
	var source = FileAccess.get_file_as_string("res://src/lab/starter_bacterium_lab.gd")
	for required in ["use_stress_body", "stress_cell_count", "_build_stress_body", "service.place_cell"]:
		if not source.contains(required):
			failures.append("Lab stress hook missing %s." % required)
	if not source.contains("ParticleEffectAdapter.setup_world_ambient(renderer)"):
		failures.append("Ambient particles should be parented to the renderer, not the lab root.")
	if source.contains("lab_camera_adapter") or source.contains("PhantomCamera"):
		failures.append("Iter A should not introduce a camera adapter or PhantomCamera.")


func _validate_lab_stress_body_build(failures: Array[String]) -> void:
	var lab = StarterBacteriumLab.new()
	lab.service = SimulationService.new()
	lab.seed = 3
	lab.stress_cell_count = 100
	var body = lab._build_stress_body()
	if body == null:
		failures.append("Lab stress body builder should return a body.")
		return
	if body.get_cell_count() != 100:
		failures.append("Lab stress body should contain 100 cells, got %d." % body.get_cell_count())
	if lab.service.get_placement_count() != 100:
		failures.append("Stress body must use SimulationService.place_cell for every cell.")
	if not body.is_body_connected():
		failures.append("Lab stress body should be connected.")
	lab.service.free()
	lab.free()


func _finish(label: String, failures: Array[String]) -> void:
	if failures.is_empty():
		print("%s: OK" % label)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
