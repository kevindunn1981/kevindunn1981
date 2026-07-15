class_name TentaclePart
extends Node3D
## A chunk of a destroyed enemy tentacle. Tumbles outward from the kill,
## then homes in on the player's ship. On arrival main.collect_part()
## either grafts a new PlayerTentacle or converts it to bonus score.

const COLLECT_RADIUS := 1.3
const MAX_LIFE := 8.0

var main: Node3D
var player: Node3D

var _velocity := Vector3.ZERO
var _age := 0.0
var _spin_axis := Vector3.UP
var _spin_speed := 0.0

func _ready() -> void:
	var mi := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.18
	mesh.height = 0.7
	mi.mesh = mesh
	mi.material_override = TubeMesh.make_material(
		Color(0.16, 0.04, 0.2), Color(1.0, 0.35, 0.9), 2.2)
	add_child(mi)

	var trail := GPUParticles3D.new()
	trail.amount = 12
	trail.lifetime = 0.5
	trail.local_coords = false
	var pm := ParticleProcessMaterial.new()
	pm.gravity = Vector3.ZERO
	pm.initial_velocity_min = 0.1
	pm.initial_velocity_max = 0.4
	pm.scale_min = 0.3
	pm.scale_max = 0.8
	var ramp := Gradient.new()
	ramp.set_color(0, Color(1.0, 0.4, 0.9, 0.7))
	ramp.set_color(1, Color(0.4, 0.1, 0.5, 0.0))
	var ramp_tex := GradientTexture1D.new()
	ramp_tex.gradient = ramp
	pm.color_ramp = ramp_tex
	trail.process_material = pm
	var quad := QuadMesh.new()
	quad.size = Vector2(0.16, 0.16)
	var qmat := StandardMaterial3D.new()
	qmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	qmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	qmat.vertex_color_use_as_albedo = true
	qmat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	quad.material = qmat
	trail.draw_pass_1 = quad
	add_child(trail)

	var dir := Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	_velocity = dir * randf_range(4.0, 7.0) + Vector3(0, randf_range(2.0, 4.0), 0)
	_spin_axis = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized()
	_spin_speed = randf_range(3.0, 8.0)

func _process(delta: float) -> void:
	_age += delta
	if _age > MAX_LIFE:
		queue_free()
		return
	rotate(_spin_axis, _spin_speed * delta)

	if _age < 0.45:
		# Explosive tumble away from the kill.
		_velocity *= pow(0.15, delta)   # heavy damping
		_velocity.y -= 6.0 * delta
		global_position += _velocity * delta
	else:
		# Home in on the ship, accelerating over time.
		if player == null or not is_instance_valid(player):
			queue_free()
			return
		var to_ship := player.global_position - global_position
		var dist := to_ship.length()
		if dist < COLLECT_RADIUS:
			if main:
				main.collect_part(global_position)
			queue_free()
			return
		var speed := minf(10.0 + (_age - 0.45) * 22.0, 34.0)
		global_position += to_ship.normalized() * speed * delta
