class_name Player
extends CharacterBody3D
## The player's ship. Everything is constructed in code from primitive
## meshes (spheres, capsules, cylinders, boxes) per the project brief.
## Carries the SpringArm3D + Camera3D rig, the starting turret, thruster
## particle systems, and up to MAX_TENTACLES grafted laser tentacles.

signal health_changed(hp: float, max_hp: float)
signal died

const MAX_HP := 100.0
const MAX_TENTACLES := 8
const SPEED := 12.0
const ACCEL := 6.0
const INVULN_TIME := 1.0

const HULL_COLOR := Color(0.10, 0.14, 0.22)
const GLOW_CYAN := Color(0.28, 0.94, 1.0)

var main: Node3D
var joystick: VirtualJoystick

var hp := MAX_HP
var dead := false
var controls_enabled := false

var _invuln := 0.0
var _shake := 0.0
var _idle_time := 0.0
var _tentacle_count := 0

var ship_visual: Node3D
var camera: Camera3D
var _spring_arm: SpringArm3D
var _turret: Turret
var _thrusters: Array[GPUParticles3D] = []

# Mount slots for grafted tentacles: rear slots fill first so the nose
# stays visually clear. Angles are degrees around the hull; the nose points
# along -Z, so 0 degrees (+Z) is the rear of the ship.
const MOUNT_ANGLES := [20.0, 340.0, 60.0, 300.0, 100.0, 260.0, 140.0, 220.0]

func _ready() -> void:
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 1.0
	shape.shape = sphere
	add_child(shape)

	_build_ship()
	_build_camera_rig()
	_build_thrusters()

	_turret = Turret.new()
	_turret.main = main
	_turret.position = Vector3(0, 0.42, -0.05)
	ship_visual.add_child(_turret)

func _build_ship() -> void:
	ship_visual = Node3D.new()
	ship_visual.name = "ShipVisual"
	add_child(ship_visual)

	var hull_mat := StandardMaterial3D.new()
	hull_mat.albedo_color = HULL_COLOR
	hull_mat.metallic = 0.55
	hull_mat.roughness = 0.35

	var glow_mat := StandardMaterial3D.new()
	glow_mat.albedo_color = GLOW_CYAN
	glow_mat.emission_enabled = true
	glow_mat.emission = GLOW_CYAN
	glow_mat.emission_energy_multiplier = 2.2

	# Main saucer hull: a squashed sphere (parabolic profile).
	var hull := MeshInstance3D.new()
	var hull_mesh := SphereMesh.new()
	hull_mesh.radius = 1.0
	hull_mesh.height = 2.0
	hull.mesh = hull_mesh
	hull.material_override = hull_mat
	hull.scale = Vector3(0.9, 0.32, 1.3)
	ship_visual.add_child(hull)

	# Cockpit canopy.
	var canopy := MeshInstance3D.new()
	var canopy_mesh := SphereMesh.new()
	canopy_mesh.radius = 0.38
	canopy_mesh.height = 0.76
	canopy.mesh = canopy_mesh
	canopy.material_override = glow_mat
	canopy.scale = Vector3(0.7, 0.5, 0.95)
	canopy.position = Vector3(0, 0.28, -0.15)
	ship_visual.add_child(canopy)

	# Engine nacelles: capsules lying along the hull sides.
	for side in [-1.0, 1.0]:
		var nacelle := MeshInstance3D.new()
		var nac_mesh := CapsuleMesh.new()
		nac_mesh.radius = 0.20
		nac_mesh.height = 1.5
		nacelle.mesh = nac_mesh
		nacelle.material_override = hull_mat
		nacelle.rotation_degrees.x = 90.0
		nacelle.position = Vector3(0.85 * side, 0.0, 0.25)
		ship_visual.add_child(nacelle)

		var exhaust := MeshInstance3D.new()
		var ex_mesh := CylinderMesh.new()
		ex_mesh.top_radius = 0.14
		ex_mesh.bottom_radius = 0.10
		ex_mesh.height = 0.12
		exhaust.mesh = ex_mesh
		exhaust.material_override = glow_mat
		exhaust.rotation_degrees.x = 90.0
		exhaust.position = Vector3(0.85 * side, 0.0, 1.02)
		ship_visual.add_child(exhaust)

	# Tail fin.
	var fin := MeshInstance3D.new()
	var fin_mesh := BoxMesh.new()
	fin_mesh.size = Vector3(0.08, 0.5, 0.7)
	fin.mesh = fin_mesh
	fin.material_override = hull_mat
	fin.position = Vector3(0, 0.35, 0.75)
	ship_visual.add_child(fin)

	# Under-glow light so the ship pops against the arena floor.
	var light := OmniLight3D.new()
	light.light_color = GLOW_CYAN
	light.light_energy = 1.4
	light.omni_range = 6.0
	light.position = Vector3(0, -0.4, 0)
	ship_visual.add_child(light)

func _build_camera_rig() -> void:
	# SpringArm3D + Camera3D attached to the player, per the brief.
	_spring_arm = SpringArm3D.new()
	_spring_arm.spring_length = 21.0
	_spring_arm.collision_mask = 0   # nothing should push the camera in
	_spring_arm.rotation_degrees.x = -72.0
	add_child(_spring_arm)

	camera = Camera3D.new()
	camera.fov = 55.0
	camera.current = true
	_spring_arm.add_child(camera)

func _build_thrusters() -> void:
	for side in [-1.0, 1.0]:
		var p := GPUParticles3D.new()
		p.amount = 24
		p.lifetime = 0.45
		p.local_coords = false
		var mat := ParticleProcessMaterial.new()
		mat.direction = Vector3(0, 0, 1)
		mat.spread = 8.0
		mat.initial_velocity_min = 6.0
		mat.initial_velocity_max = 9.0
		mat.gravity = Vector3.ZERO
		mat.scale_min = 0.5
		mat.scale_max = 1.0
		var ramp := Gradient.new()
		ramp.set_color(0, Color(0.5, 0.98, 1.0, 0.9))
		ramp.set_color(1, Color(0.1, 0.3, 1.0, 0.0))
		var ramp_tex := GradientTexture1D.new()
		ramp_tex.gradient = ramp
		mat.color_ramp = ramp_tex
		p.process_material = mat
		var quad := QuadMesh.new()
		quad.size = Vector2(0.22, 0.22)
		var qmat := StandardMaterial3D.new()
		qmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		qmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		qmat.vertex_color_use_as_albedo = true
		qmat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
		quad.material = qmat
		p.draw_pass_1 = quad
		p.position = Vector3(0.85 * side, 0.0, 1.1)
		ship_visual.add_child(p)
		_thrusters.append(p)

func _physics_process(delta: float) -> void:
	_invuln = maxf(_invuln - delta, 0.0)
	_idle_time += delta

	# Camera shake decay, applied as camera offsets.
	_shake = maxf(_shake - delta * 3.0, 0.0)
	if camera:
		camera.h_offset = randf_range(-1, 1) * _shake * 0.4
		camera.v_offset = randf_range(-1, 1) * _shake * 0.4

	# Invulnerability blink.
	if ship_visual:
		ship_visual.visible = dead == false and (_invuln <= 0.0 or fmod(_idle_time, 0.16) < 0.09)

	if dead:
		velocity = Vector3.ZERO
		return

	var input := Vector2.ZERO
	if controls_enabled:
		if joystick:
			input = joystick.output
		if input == Vector2.ZERO:
			# Keyboard fallback for desktop testing.
			input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	var dir := Vector3(input.x, 0, input.y)
	if dir.length() > 1.0:
		dir = dir.normalized()
	velocity = velocity.lerp(dir * SPEED, minf(ACCEL * delta, 1.0))
	move_and_slide()
	global_position.y = 0.0

	# Keep the ship inside the arena.
	if main:
		var flat := Vector2(global_position.x, global_position.z)
		var limit: float = main.arena_radius - 1.2
		if flat.length() > limit:
			flat = flat.normalized() * limit
			global_position.x = flat.x
			global_position.z = flat.y

	# Face the direction of travel (nose is -Z), with a gentle idle bob.
	if velocity.length() > 0.8:
		var target_yaw := atan2(-velocity.x, -velocity.z)
		ship_visual.rotation.y = lerp_angle(ship_visual.rotation.y, target_yaw, minf(10.0 * delta, 1.0))
	ship_visual.position.y = sin(_idle_time * 1.8) * 0.08
	ship_visual.rotation.z = lerp(ship_visual.rotation.z, -velocity.dot(ship_visual.global_basis.x) * 0.02, minf(8.0 * delta, 1.0))

	var thrust := clampf(velocity.length() / SPEED, 0.0, 1.0)
	for t in _thrusters:
		t.amount_ratio = maxf(thrust, 0.15)

func take_damage(amount: float) -> void:
	if dead or _invuln > 0.0:
		return
	hp = maxf(hp - amount, 0.0)
	_invuln = INVULN_TIME
	_shake = 1.0
	health_changed.emit(hp, MAX_HP)
	if hp <= 0.0:
		dead = true
		controls_enabled = false
		ship_visual.visible = false
		_turret.set_process(false)
		died.emit()

func heal(amount: float) -> void:
	if dead:
		return
	hp = minf(hp + amount, MAX_HP)
	health_changed.emit(hp, MAX_HP)

func shake(amount: float) -> void:
	_shake = maxf(_shake, amount)

func tentacle_count() -> int:
	return _tentacle_count

## Grafts a new laser tentacle onto the hull. Returns false when full.
func add_tentacle() -> bool:
	if dead or _tentacle_count >= MAX_TENTACLES:
		return false
	var angle := deg_to_rad(MOUNT_ANGLES[_tentacle_count])
	var out_dir := Vector3(sin(angle), 0, cos(angle))
	var tentacle := PlayerTentacle.new()
	tentacle.main = main
	tentacle.out_dir = out_dir
	tentacle.position = Vector3(out_dir.x * 0.9, 0.18, out_dir.z * 1.15)
	ship_visual.add_child(tentacle)
	_tentacle_count += 1
	return true
