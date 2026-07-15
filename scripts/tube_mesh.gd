class_name TubeMesh
## Static helper that rebuilds an ImmediateMesh as a tapered tube skinned
## along a run of spline sample points. This is the single mesh generator
## behind every tentacle in the game (enemy and player-grafted alike).
##
## Winding is not guaranteed, so materials used with these tubes should set
## cull_mode = CULL_DISABLED.

## Rebuilds `mesh` in place as a tube following `points`.
## The radius starts at base_radius and tapers toward the tip.
static func rebuild(mesh: ImmediateMesh, points: PackedVector3Array, base_radius: float, sides: int = 8, taper: float = 0.88) -> void:
	mesh.clear_surfaces()
	var count := points.size()
	if count < 2:
		return

	# Build one vertex ring per point.
	var ring_centers: Array[Vector3] = []
	var ring_verts: Array = []   # Array of PackedVector3Array
	var ring_norms: Array = []
	var last_tangent := Vector3.FORWARD
	for i in count:
		var t := float(i) / float(count - 1)
		var radius := base_radius * (1.0 - taper * t)
		var tangent: Vector3
		if i == 0:
			tangent = points[1] - points[0]
		elif i == count - 1:
			tangent = points[i] - points[i - 1]
		else:
			tangent = points[i + 1] - points[i - 1]
		if tangent.length_squared() < 0.000001:
			tangent = last_tangent
		else:
			tangent = tangent.normalized()
			last_tangent = tangent
		var ref := Vector3.UP if absf(tangent.dot(Vector3.UP)) < 0.95 else Vector3.RIGHT
		var side_axis := ref.cross(tangent).normalized()
		var up_axis := tangent.cross(side_axis).normalized()
		var verts := PackedVector3Array()
		var norms := PackedVector3Array()
		for s in sides:
			var a := TAU * float(s) / float(sides)
			var normal := side_axis * cos(a) + up_axis * sin(a)
			verts.append(points[i] + normal * radius)
			norms.append(normal)
		ring_centers.append(points[i])
		ring_verts.append(verts)
		ring_norms.append(norms)

	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in count - 1:
		var va: PackedVector3Array = ring_verts[i]
		var na: PackedVector3Array = ring_norms[i]
		var vb: PackedVector3Array = ring_verts[i + 1]
		var nb: PackedVector3Array = ring_norms[i + 1]
		for s in sides:
			var s2 := (s + 1) % sides
			_add_tri(mesh, va[s], na[s], vb[s], nb[s], vb[s2], nb[s2])
			_add_tri(mesh, va[s], na[s], vb[s2], nb[s2], va[s2], na[s2])

	# Cap the tip with a small fan so the tentacle ends in a point.
	var tip_dir := (points[count - 1] - points[count - 2])
	if tip_dir.length_squared() < 0.000001:
		tip_dir = last_tangent
	tip_dir = tip_dir.normalized()
	var tip := points[count - 1] + tip_dir * base_radius * (1.0 - taper) * 2.0
	var vl: PackedVector3Array = ring_verts[count - 1]
	var nl: PackedVector3Array = ring_norms[count - 1]
	for s in sides:
		var s2 := (s + 1) % sides
		_add_tri(mesh, vl[s], nl[s], tip, tip_dir, vl[s2], nl[s2])
	mesh.surface_end()

static func _add_tri(mesh: ImmediateMesh, v0: Vector3, n0: Vector3, v1: Vector3, n1: Vector3, v2: Vector3, n2: Vector3) -> void:
	mesh.surface_set_normal(n0)
	mesh.surface_add_vertex(v0)
	mesh.surface_set_normal(n1)
	mesh.surface_add_vertex(v1)
	mesh.surface_set_normal(n2)
	mesh.surface_add_vertex(v2)

## Convenience: builds the shared emissive tentacle material.
static func make_material(albedo: Color, emission: Color, emission_energy: float = 1.4) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = albedo
	mat.emission_enabled = true
	mat.emission = emission
	mat.emission_energy_multiplier = emission_energy
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.roughness = 0.6
	return mat
