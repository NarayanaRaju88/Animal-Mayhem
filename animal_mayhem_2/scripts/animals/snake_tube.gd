class_name SnakeTube
extends RefCounted
## Tapered elliptical snake with a flattened belly and dorsal ridge. Not a capsule chain.


static func rebuild(mi: MeshInstance3D, points: PackedVector3Array, mat: Material) -> void:
	if mi == null or points.size() < 4:
		return
	var radial := 14
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var n := points.size()
	var rings: Array[PackedVector3Array] = []
	var uvs: Array[PackedVector2Array] = []
	for i in n:
		var p: Vector3 = points[i]
		var tangent := Vector3(0, 0, -1)
		if i < n - 1:
			tangent = points[i + 1] - p
		elif i > 0:
			tangent = p - points[i - 1]
		if tangent.length_squared() < 0.0001:
			tangent = Vector3(0, 0, -1)
		tangent = tangent.normalized()
		var binorm := tangent.cross(Vector3.UP)
		if binorm.length_squared() < 0.0001:
			binorm = tangent.cross(Vector3.RIGHT)
		binorm = binorm.normalized()
		var norm := binorm.cross(tangent).normalized()
		var t := float(i) / float(maxi(n - 1, 1))
		var rx := _radius_x(t)
		var ry := rx * 0.62
		var ring := PackedVector3Array()
		var uvring := PackedVector2Array()
		for r in radial:
			var a := TAU * float(r) / float(radial)
			var sa := sin(a)
			var yk := 0.42 if sa < 0.0 else 1.06
			if sa > 0.58:
				yk = 1.2
			ring.append(p + binorm * cos(a) * rx + norm * sa * ry * yk)
			uvring.append(Vector2(float(r) / float(radial) * 4.0, t * 12.0))
		rings.append(ring)
		uvs.append(uvring)
	for i in n - 1:
		for r in radial:
			var r2 := (r + 1) % radial
			_quad(st, rings[i][r], rings[i + 1][r], rings[i + 1][r2], rings[i][r2], uvs[i][r], uvs[i + 1][r], uvs[i + 1][r2], uvs[i][r2])
	st.generate_normals()
	st.generate_tangents()
	mi.mesh = st.commit()
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON


static func _radius_x(t: float) -> float:
	## Thick mid-body, distinct neck, aggressive tail taper — not a constant pipe.
	if t < 0.10:
		return lerpf(0.108, 0.198, t / 0.10)
	if t < 0.55:
		return lerpf(0.198, 0.162, (t - 0.10) / 0.45)
	return lerpf(0.162, 0.016, pow((t - 0.55) / 0.45, 1.25))


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
