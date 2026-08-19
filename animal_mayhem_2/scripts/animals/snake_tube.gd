class_name SnakeTube
extends RefCounted
## Tapered elliptical snake with a flattened belly and dorsal ridge. Not a capsule chain.


static func rebuild(mi: MeshInstance3D, points: PackedVector3Array, mat: Material) -> void:
	if mi == null or points.size() < 4:
		return
	var radial := 12
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
		var neck := 1.0 if t > 0.08 else lerpf(1.18, 1.0, t / 0.08)
		var rx := lerpf(0.15, 0.028, pow(t, 0.85)) * neck
		var ry := lerpf(0.095, 0.018, pow(t, 0.9)) * neck
		var ring := PackedVector3Array()
		var uvring := PackedVector2Array()
		for r in radial:
			var a := TAU * float(r) / float(radial)
			var yk := 0.52 if sin(a) < 0.0 else 1.08
			if sin(a) > 0.55:
				yk = 1.22
			ring.append(p + binorm * cos(a) * rx + norm * sin(a) * ry * yk)
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
