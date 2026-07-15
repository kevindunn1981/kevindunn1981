class_name Tentacle
extends Node3D
## An enemy tentacle. Anchored just outside the visible arena, it reaches
## in toward the player along an animated Curve3D spline (Catmull-Rom style
## smoothing) with one of three motion styles: WAVE, SWING or SWIRL.
## The tube mesh is reskinned every frame with TubeMesh.rebuild().
##
## Damage from projectiles/lasers is applied through take_damage(); when hp
## reaches zero the tentacle emits `died` and main breaks it into
## TentacleParts that fly to the player's ship.

signal died(tentacle: Tentacle)

enum Style { WAVE, SWING, SWIRL }

const CONTROL_POINTS := 6
const RENDER_POINTS := 16
const TIP_HIT_POINTS := 5      # how many tip samples can strike the player
const PLAYER_HIT_RADIUS := 1.5
const CONTACT_DAMAGE := 12.0
const RECOIL_TIME := 1.5

var main: Node3D
var player: Node3D

var style: Style = Style.WAVE
var full_length := 16.0
var girth := 0.55
var max_hp := 30.0
var amplitude := 3.0
var speed_scale := 1.0
var track_speed := 0.4      # radians/sec of aim tracking toward the player
var score_value := 15

var hp := 30.0
var dying := false

var _time := 0.0
var _phase := randf() * TAU
var _cur_len := 0.6
var _recoil := 0.0
var _flash := 0.0
var _aim := Vector3.FORWARD
var _curve := Curve3D.new()
var _mesh := ImmediateMesh.new()
var _mat: StandardMaterial3D
var _points_global := PackedVector3Array()
var _tip_particles: GPUParticles3D

const BASE_EMISSION_ENERGY := 1.2

func _ready() -> void:
	add_to_group("tentacles")
	hp = max_hp
	_time = randf() * 30.0
	_curve.bake_interval = 0.6

	var mi := MeshInstance3D.new()
	mi.mesh = _mesh
	_mat = TubeMesh.make_material(
		Color(0.16, 0.04, 0.2), Color(0.9, 0.2, 0.85), BASE_EMISSION_ENERGY)
	mi.material_override = _mat
	add_child(mi)

	# Spore particles drifting off the tip.
	_tip_particles = GPUParticles3D.new()
	_tip_particles.amount = 10
	_tip_particles.lifetime = 1.1
	_tip_particles.local_coords = false
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pm.emission_sphere_radius = 0.35
	pm.gravity = Vector3(0, 0.6, 0)
	pm.initial_velocity_min = 0.3
	pm.initial_velocity_max = 1.2
	pm.scale_min = 0.4
	pm.scale_max = 1.0
	var ramp := Gradient.new()
	ramp.set_color(0, Color(1.0, 0.35, 0.9, 0.8))
	ramp.set_color(1, Color(0.5, 0.1, 0.6, 0.0))
	var ramp_tex := GradientTexture1D.new()
	ramp_tex.gradient = ramp
	pm.color_ramp = ramp_tex
	_tip_particles.process_material = pm
	var quad := QuadMesh.new()
	quad.size = Vector2(0.2, 0.2)
	var qmat := StandardMaterial3D.new()
	qmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	qmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	qmat.vertex_color_use_as_albedo = true
	qmat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	quad.material = qmat
	_tip_particles.draw_pass_1 = quad
	add_child(_tip_particles)

	# Initial aim: toward the arena center.
	var inward := -global_position
	inward.y = 0.0
	_aim = inward.normalized() if inward.length() > 0.1 else Vector3.FORWARD

func _process(delta: float) -> void:
	if dying:
		return
	_time += delta
	_flash = maxf(_flash - delta * 4.0, 0.0)
	_mat.emission_energy_multiplier = BASE_EMISSION_ENERGY + _flash * 3.0

	# Length: grows in when spawned, shrinks briefly after striking.
	var target_len := full_length
	var grow_speed := 4.0
	if _recoil > 0.0:
		_recoil -= delta
		target_len = full_length * 0.35
		grow_speed = 10.0
	_cur_len = move_toward(_cur_len, target_len, grow_speed * delta)

	# Slowly track the player so dodging matters.
	if player and is_instance_valid(player):
		var to_p := player.global_position - global_position
		to_p.y = 0.0
		if to_p.length() > 0.5:
			var desired := atan2(to_p.x, to_p.z)
			var current := atan2(_aim.x, _aim.z)
			var diff := wrapf(desired - current, -PI, PI)
			current += clampf(diff, -track_speed * delta, track_speed * delta)
			_aim = Vector3(sin(current), 0, cos(current))

	_rebuild()
	_check_player_hit()

func _rebuild() -> void:
	var perp := _aim.cross(Vector3.UP)
	var ctrl := PackedVector3Array()
	for i in CONTROL_POINTS:
		var t := float(i) / float(CONTROL_POINTS - 1)
		var d := _cur_len * t
		var p := _aim * d
		match style:
			Style.WAVE:
				p += perp * sin(_phase + _time * 2.2 * speed_scale + t * 4.5) * amplitude * t
				p.y += sin(_phase + _time * 1.7 * speed_scale + t * 3.0) * 0.7 * t
			Style.SWING:
				var ang := sin(_phase + _time * 1.15 * speed_scale) * 1.1 * t
				p = _aim.rotated(Vector3.UP, ang) * d
				p.y += sin(_phase + _time * 2.0 * speed_scale + t * 5.0) * 0.35 * t
			Style.SWIRL:
				var a := _phase + _time * 2.7 * speed_scale + t * 5.5
				p += perp * cos(a) * amplitude * 0.7 * t
				p.y += (sin(a) * amplitude * 0.3 + 0.3) * t
		p.y = maxf(p.y, -0.3) + 0.4
		ctrl.append(p)

	# Feed the control points into a Curve3D with Catmull-Rom style
	# handles so the rendered tube is a genuinely smooth spline.
	_curve.clear_points()
	for p in ctrl:
		_curve.add_point(p)
	var n := ctrl.size()
	for i in n:
		var prev := ctrl[maxi(i - 1, 0)]
		var next := ctrl[mini(i + 1, n - 1)]
		var handle := (next - prev) / 6.0
		_curve.set_point_in(i, -handle)
		_curve.set_point_out(i, handle)

	var render := PackedVector3Array()
	var baked_len := _curve.get_baked_length()
	for j in RENDER_POINTS:
		render.append(_curve.sample_baked(baked_len * float(j) / float(RENDER_POINTS - 1)))

	TubeMesh.rebuild(_mesh, render, girth)
	_points_global.clear()
	for p in render:
		_points_global.append(to_global(p))
	_tip_particles.position = render[RENDER_POINTS - 1]

func _check_player_hit() -> void:
	if main == null or not main.is_playing():
		return
	if player == null or not is_instance_valid(player) or _recoil > 0.0:
		return
	var start := _points_global.size() - TIP_HIT_POINTS
	for i in range(maxi(start, 0), _points_global.size()):
		if _points_global[i].distance_to(player.global_position) < PLAYER_HIT_RADIUS:
			player.take_damage(CONTACT_DAMAGE)
			_recoil = RECOIL_TIME
			main.spawn_burst(_points_global[i], Color(1.0, 0.3, 0.9), 14, 5.0)
			break

func hit_points() -> PackedVector3Array:
	return _points_global

## A good aim point for turrets/lasers: ~70% of the way along the spline.
func target_point() -> Vector3:
	if _points_global.is_empty():
		return global_position
	return _points_global[int(_points_global.size() * 0.7)]

func take_damage(amount: float) -> void:
	if dying:
		return
	hp -= amount
	_flash = 1.0
	if hp <= 0.0:
		dying = true
		died.emit(self)
		queue_free()
