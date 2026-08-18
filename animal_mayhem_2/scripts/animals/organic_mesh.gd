class_name OrganicMesh
extends RefCounted
## Lathed / lofted meshes so animals are not a pile of obvious capsules.


static func loft(centers: PackedVector3Array, radii: PackedFloat32Array, radial := 10) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var n := centers.size()
	if n < 2 or radii.size() != n:
		return ArrayMesh.new()
	var rings: Array[PackedVector3Array] = []
	var uvs: Array[PackedVector2Array] = []
	for i in n:
		var tangent := Vector3(0, 0, 1)
		if i < n - 1:
			tangent = centers[i + 1] - centers[i]
		else:
			tangent = centers[i] - centers[i - 1]
		if tangent.length_squared() < 0.00001:
			tangent = Vector3(0, 0, 1)
		tangent = tangent.normalized()
		var binorm := tangent.cross(Vector3.UP)
		if binorm.length_squared() < 0.00001:
			binorm = tangent.cross(Vector3.RIGHT)
		binorm = binorm.normalized()
		var norm := binorm.cross(tangent).normalized()
		var ring := PackedVector3Array()
		var uvring := PackedVector2Array()
		for r in radial:
			var a := TAU * float(r) / float(radial)
			var squash := 0.82 + 0.18 * absf(cos(a))
			var p: Vector3 = centers[i] + (binorm * cos(a) + norm * sin(a)) * radii[i] * squash
			ring.append(p)
			uvring.append(Vector2(float(r) / float(radial), float(i) / float(maxi(n - 1, 1))))
		rings.append(ring)
		uvs.append(uvring)
	for i in n - 1:
		for r in radial:
			var r2 := (r + 1) % radial
			_quad(st, rings[i][r], rings[i + 1][r], rings[i + 1][r2], rings[i][r2], uvs[i][r], uvs[i + 1][r], uvs[i + 1][r2], uvs[i][r2])
	st.generate_normals()
	st.generate_tangents()
	return st.commit()


static func curve_horn(points: PackedVector3Array, start_r: float, end_r: float, radial := 7) -> ArrayMesh:
	var radii := PackedFloat32Array()
	for i in points.size():
		var t := float(i) / float(maxi(points.size() - 1, 1))
		radii.append(lerpf(start_r, end_r, t))
	return loft(points, radii, radial)


static func _quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, ua: Vector2, ub: Vector2, uc: Vector2, ud: Vector2) -> void:
	st.set_uv(ua)
	st.add_vertex(a)
	st.set_uv(ub)
	st.add_vertex(b)
	st.set_uv(uc)
	st.add_vertex(c)
	st.set_uv(ua)
	st.add_vertex(a)
	st.set_uv(uc)
	st.add_vertex(c)
	st.set_uv(ud)
	st.add_vertex(d)
