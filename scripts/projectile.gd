class_name Projectile
extends Node3D
## Turret bolt: a small emissive sphere moving in a straight line.
## Collision is a simple distance test against tentacle spline points,
## handled by main.damage_tentacle_at().

const SPEED := 28.0
const DAMAGE := 8.0
const HIT_RADIUS := 1.1
const LIFETIME := 1.6

var main: Node3D
var direction := Vector3.FORWARD

var _life := LIFETIME

func _ready() -> void:
	var m := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.14
	mesh.height = 0.28
	m.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.7, 1.0, 1.0)
	mat.emission_enabled = true
	mat.emission = Color(0.28, 0.94, 1.0)
	mat.emission_energy_multiplier = 3.5
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.material_override = mat
	m.scale = Vector3(1, 1, 2.2)   # stretched along travel for a bolt look
	add_child(m)
	if direction.length_squared() > 0.001:
		look_at(global_position + direction, Vector3.UP)

func _process(delta: float) -> void:
	_life -= delta
	if _life <= 0.0:
		queue_free()
		return
	global_position += direction * SPEED * delta
	if main and main.damage_tentacle_at(global_position, HIT_RADIUS, DAMAGE):
		main.spawn_burst(global_position, Color(0.28, 0.94, 1.0), 10, 3.5)
		queue_free()
