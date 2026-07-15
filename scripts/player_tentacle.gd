class_name PlayerTentacle
extends Node3D
## A tentacle grafted onto the player's ship, rebuilt from a defeated enemy
## part. Waves idly using the same spline-tube generator as the enemies
## (rising on a parabolic arc) and periodically fires a hitscan laser at
## the nearest enemy tentacle via main.fire_laser().

const LENGTH := 2.8
const POINTS := 9
const GIRTH := 0.15
const RANGE := 26.0
const DAMAGE := 11.0

var main: Node3D
var out_dir := Vector3.BACK   # local outward direction from the hull

var _time := randf() * 10.0
var _phase := randf() * TAU
var _cooldown := randf_range(0.8, 1.6)
var _mesh := ImmediateMesh.new()
var _tip_local := Vector3.ZERO

func _ready() -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = _mesh
	mi.material_override = TubeMesh.make_material(
		Color(0.08, 0.35, 0.4), Color(0.2, 0.9, 1.0), 1.6)
	add_child(mi)

	# A soft spark at the tip marks it as a weapon.
	var spark := GPUParticles3D.new()
	spark.name = "TipSpark"
	spark.amount = 6
	spark.lifetime = 0.6
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pm.emission_sphere_radius = 0.1
	pm.gravity = Vector3.ZERO
	pm.initial_velocity_min = 0.2
	pm.initial_velocity_max = 0.6
	pm.scale_min = 0.3
	pm.scale_max = 0.7
	pm.color = Color(0.4, 1.0, 1.0, 0.8)
	spark.process_material = pm
	var quad := QuadMesh.new()
	quad.size = Vector2(0.12, 0.12)
	var qmat := StandardMaterial3D.new()
	qmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	qmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	qmat.vertex_color_use_as_albedo = true
	qmat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	quad.material = qmat
	spark.draw_pass_1 = quad
	add_child(spark)

func _process(delta: float) -> void:
	_time += delta
	var perp := out_dir.cross(Vector3.UP)
	var pts := PackedVector3Array()
	for i in POINTS:
		var t := float(i) / float(POINTS - 1)
		var p := out_dir * LENGTH * t
		# Parabolic rise so grafts arc up and outward from the hull.
		p.y += 1.6 * t - 0.55 * t * t
		p += perp * sin(_phase + _time * 3.2 + t * 4.0) * 0.45 * t
		p.y += sin(_phase + _time * 2.1 + t * 3.0) * 0.18 * t
		pts.append(p)
	TubeMesh.rebuild(_mesh, pts, GIRTH, 6)
	_tip_local = pts[POINTS - 1]
	var spark := get_node_or_null("TipSpark")
	if spark:
		spark.position = _tip_local

	if main == null or not main.is_playing():
		return
	_cooldown -= delta
	if _cooldown <= 0.0:
		var tip := to_global(_tip_local)
		var target: Variant = main.get_nearest_tentacle_point(tip, RANGE)
		if target != null:
			_cooldown = randf_range(1.1, 1.9)
			main.fire_laser(tip, target, DAMAGE)
