class_name ParticleEffectAdapter
extends RefCounted

const AMBIENT_PARTICLE_TEXTURE = preload("res://addons/kenney_particle_pack/circle_05.png")


static func setup_world_ambient(parent: Node) -> GPUParticles2D:
	if parent == null:
		return null
	var particles = parent.get_node_or_null("AmbientParticleDrift")
	if particles is GPUParticles2D:
		return particles

	particles = GPUParticles2D.new()
	particles.name = "AmbientParticleDrift"
	particles.amount = 42
	particles.lifetime = 8.0
	particles.preprocess = 8.0
	particles.texture = AMBIENT_PARTICLE_TEXTURE
	particles.position = Vector2.ZERO
	particles.visibility_rect = Rect2(Vector2(-1200, -900), Vector2(2400, 1800))
	particles.z_index = 1
	particles.visible = false
	particles.emitting = false

	var material = ParticleProcessMaterial.new()
	material.direction = Vector3(0.0, -1.0, 0.0)
	material.spread = 180.0
	material.initial_velocity_min = 4.0
	material.initial_velocity_max = 14.0
	material.gravity = Vector3(0.0, -2.0, 0.0)
	material.scale_min = 0.015
	material.scale_max = 0.045
	particles.process_material = material

	parent.add_child(particles)
	return particles


static func set_enabled(particles: Node, enabled: bool) -> void:
	if particles is GPUParticles2D:
		particles.visible = enabled
		particles.emitting = enabled
