class_name Turret
extends Node3D
## The player's starting weapon: a small auto-aiming turret built from
## cylinder primitives. Tracks the nearest enemy tentacle and fires
## projectiles through main.spawn_projectile().

const RANGE := 22.0
const FIRE_INTERVAL := 0.32

var main: Node3D

var _cooldown := 0.0
var _yaw: Node3D
var _muzzle: Node3D

func _ready() -> void:
	var base_mat := StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.16, 0.2, 0.3)
	base_mat.metallic = 0.6
	base_mat.roughness = 0.3

	var glow_mat := StandardMaterial3D.new()
	glow_mat.albedo_color = Color(0.28, 0.94, 1.0)
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(0.28, 0.94, 1.0)
	glow_mat.emission_energy_multiplier = 2.0

	var base := MeshInstance3D.new()
	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = 0.18
	base_mesh.bottom_radius = 0.24
	base_mesh.height = 0.16
	base.mesh = base_mesh
	base.material_override = base_mat
	add_child(base)

	_yaw = Node3D.new()
	_yaw.position = Vector3(0, 0.1, 0)
	add_child(_yaw)

	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.16
	head_mesh.height = 0.32
	head.mesh = head_mesh
	head.material_override = base_mat
	_yaw.add_child(head)

	var barrel := MeshInstance3D.new()
	var barrel_mesh := CylinderMesh.new()
	barrel_mesh.top_radius = 0.05
	barrel_mesh.bottom_radius = 0.05
	barrel_mesh.height = 0.65
	barrel.mesh = barrel_mesh
	barrel.material_override = base_mat
	barrel.rotation_degrees.x = 90.0
	barrel.position = Vector3(0, 0.06, -0.35)
	_yaw.add_child(barrel)

	var tip := MeshInstance3D.new()
	var tip_mesh := CylinderMesh.new()
	tip_mesh.top_radius = 0.065
	tip_mesh.bottom_radius = 0.065
	tip_mesh.height = 0.08
	tip.mesh = tip_mesh
	tip.material_override = glow_mat
	tip.rotation_degrees.x = 90.0
	tip.position = Vector3(0, 0.06, -0.66)
	_yaw.add_child(tip)

	_muzzle = Node3D.new()
	_muzzle.position = Vector3(0, 0.06, -0.72)
	_yaw.add_child(_muzzle)

func _process(delta: float) -> void:
	if main == null or not main.is_playing():
		return
	_cooldown -= delta
	var target: Variant = main.get_nearest_tentacle_point(global_position, RANGE)
	if target == null:
		return
	var target_pos: Vector3 = target
	var flat := Vector3(target_pos.x, _yaw.global_position.y, target_pos.z)
	if flat.distance_squared_to(_yaw.global_position) > 0.01:
		_yaw.look_at(flat, Vector3.UP)
	if _cooldown <= 0.0:
		_cooldown = FIRE_INTERVAL
		var dir := (target_pos - _muzzle.global_position).normalized()
		main.spawn_projectile(_muzzle.global_position, dir)
