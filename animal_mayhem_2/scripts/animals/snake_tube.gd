class_name SnakeTube
extends RefCounted
## Builds a tapered tube along spline points so the snake is not a capsule chain.


static func rebuild(mi: MeshInstance3D, points: PackedVector3Array, mat: Material) -> void:
	if mi == null or points.size() < 3:
		return
	var radial := 7
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rings: Array[PackedVector3Array] = []
	var n := points.size()
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
		var radius := 0.15 - float(i) / float(n) * 0.09
		var ring := PackedVector3Array()
		for r in radial:
			var a := TAU * float(r) / float(radial)
			ring.append(p + (binorm * cos(a) + norm * sin(a)) * radius)
		rings.append(ring)
	for i in n - 1:
		for r in radial:
			var r2 := (r + 1) % radial
			_tri(st, rings[i][r], rings[i + 1][r], rings[i + 1][r2])
			_tri(st, rings[i][r], rings[i + 1][r2], rings[i][r2])
	st.generate_normals()
	mi.mesh = st.commit()
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON


static func _tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.add_vertex(a)
	st.add_vertex(b)
	st.add_vertex(c)
