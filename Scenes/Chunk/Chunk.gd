extends MeshInstance

var world

const voxel_size: int = 1

var surface_tool = SurfaceTool.new()

var render_mesh
var render_mesh_vertices = []
var render_mesh_normals = []
var render_mesh_indices = []
var render_mesh_uvs = []

var voxels_map

func _ready():
	update()

func update():
	render_mesh_vertices = []
	render_mesh_normals = []
	render_mesh_indices = []
	render_mesh_uvs = []
	
	#voxels_map = world.chunks_map[self]		# Get chunk map
	for x in range(0, len(voxels_map)):		# Loop through every block of the chunk
		for z in range(0, len(voxels_map[x])):
			for y in range(0, len(voxels_map[x][z])):
				if voxels_map[x][z][y] != null:			# If not air: make voxel
					_make_voxel(x, y, z, voxels_map[x][z][y])
					
	_render_chunk()
					

func _render_chunk() -> void:
	surface_tool.clear()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in range(0, render_mesh_vertices.size()):
		surface_tool.add_normal(render_mesh_normals[i])
		surface_tool.add_uv(render_mesh_uvs[i])
		surface_tool.add_vertex(render_mesh_vertices[i])
	
	for i in range(0, render_mesh_indices.size()):
		surface_tool.add_index(render_mesh_indices[i])
	
	surface_tool.generate_tangents()
	
	render_mesh = surface_tool.commit()
	self.mesh = render_mesh
	$StaticBody/CollisionShape.shape = render_mesh.create_trimesh_shape()
	
	
func _make_voxel(x, y, z, voxel_id) -> void:
	x *= voxel_size
	y *= voxel_size
	z *= voxel_size
	
	if _is_in_bound(x, y+1, z):
		if !_is_voxel_at(x, y+1, z):
			make_voxel_face(x, y, z, "TOP", voxel_id)
	else:
		make_voxel_face(x, y, z, "TOP", voxel_id)
		
	if _is_in_bound(x, y-1, z):
		if !_is_voxel_at(x, y-1, z):
			make_voxel_face(x, y, z, "BOTTOM", voxel_id)
	else:
		make_voxel_face(x, y, z, "BOTTOM", voxel_id)
		
	if _is_in_bound(x+1, y, z):
		if !_is_voxel_at(x+1, y, z):
			make_voxel_face(x, y, z, "EAST", voxel_id)
	else:
		make_voxel_face(x, y, z, "EAST", voxel_id)
		
	if _is_in_bound(x-1, y, z):
		if !_is_voxel_at(x-1, y, z):
			make_voxel_face(x, y, z, "WEST", voxel_id)
	else:
		make_voxel_face(x, y, z, "WEST", voxel_id)
	
	if _is_in_bound(x, y, z+1):
		if !_is_voxel_at(x, y, z+1):
			make_voxel_face(x, y, z, "NORTH", voxel_id)
	else:
		make_voxel_face(x, y, z, "NORTH", voxel_id)
	
	if _is_in_bound(x, y, z-1):
		if !_is_voxel_at(x, y, z-1):
			make_voxel_face(x, y, z, "SOUTH", voxel_id)
	else:
		make_voxel_face(x, y, z, "SOUTH", voxel_id)
	
	
	
func make_voxel_face(x, y, z, face, voxel_id) -> void:
	var voxel_texture_unit = 1.0 / (96 / 32);
	var voxel_data = VxDict.getVx(voxel_id)
	var uv_position = voxel_data["texture"]
	if (voxel_data.has("texture_" + face) == true):
		uv_position = voxel_data["texture_" + face]
	
	match face:
		"TOP":
			_make_voxel_face_top(x, y, z)
		"BOTTOM":
			_make_voxel_face_bottom(x, y, z)
		"EAST":
			_make_voxel_face_east(x, y, z)
		"WEST":
			_make_voxel_face_west(x, y, z)
		"NORTH":
			_make_voxel_face_north(x, y, z)
		"SOUTH":
			_make_voxel_face_south(x, y, z)
			
	render_mesh_uvs.append(Vector2( (voxel_texture_unit * uv_position.x), (voxel_texture_unit * uv_position.y) + voxel_texture_unit));
	render_mesh_uvs.append(Vector2( (voxel_texture_unit * uv_position.x) + voxel_texture_unit, (voxel_texture_unit * uv_position.y) + voxel_texture_unit));
	render_mesh_uvs.append(Vector2( (voxel_texture_unit * uv_position.x) + voxel_texture_unit, (voxel_texture_unit * uv_position.y)) );
	render_mesh_uvs.append(Vector2( (voxel_texture_unit * uv_position.x), (voxel_texture_unit * uv_position.y) ));
	
	render_mesh_indices.append(render_mesh_vertices.size() - 4)
	render_mesh_indices.append(render_mesh_vertices.size() - 3)
	render_mesh_indices.append(render_mesh_vertices.size() - 1)
	render_mesh_indices.append(render_mesh_vertices.size() - 3)
	render_mesh_indices.append(render_mesh_vertices.size() - 2)
	render_mesh_indices.append(render_mesh_vertices.size() - 1)


func _make_voxel_face_top(x, y, z) -> void:
	render_mesh_vertices.append(Vector3(x, y + voxel_size, z));
	render_mesh_vertices.append(Vector3(x + voxel_size, y + voxel_size, z));
	render_mesh_vertices.append(Vector3(x + voxel_size, y + voxel_size, z + voxel_size));
	render_mesh_vertices.append(Vector3(x, y + voxel_size, z + voxel_size));
	
	render_mesh_normals.append(Vector3(0, 1, 0));
	render_mesh_normals.append(Vector3(0, 1, 0));
	render_mesh_normals.append(Vector3(0, 1, 0));
	render_mesh_normals.append(Vector3(0, 1, 0));
	
 
func _make_voxel_face_bottom(x, y, z) -> void:
	render_mesh_vertices.append(Vector3(x, y, z + voxel_size));
	render_mesh_vertices.append(Vector3(x + voxel_size, y, z + voxel_size));
	render_mesh_vertices.append(Vector3(x + voxel_size, y, z));
	render_mesh_vertices.append(Vector3(x, y, z));
	
	render_mesh_normals.append(Vector3(0, -1, 0));
	render_mesh_normals.append(Vector3(0, -1, 0));
	render_mesh_normals.append(Vector3(0, -1, 0));
	render_mesh_normals.append(Vector3(0, -1, 0));
	
 
func _make_voxel_face_north(x, y, z) -> void:
	render_mesh_vertices.append(Vector3(x + voxel_size, y, z + voxel_size));
	render_mesh_vertices.append(Vector3(x, y, z + voxel_size));
	render_mesh_vertices.append(Vector3(x, y + voxel_size, z + voxel_size));
	render_mesh_vertices.append(Vector3(x + voxel_size, y + voxel_size, z + voxel_size));
	
	render_mesh_normals.append(Vector3(0, 0, 1));
	render_mesh_normals.append(Vector3(0, 0, 1));
	render_mesh_normals.append(Vector3(0, 0, 1));
	render_mesh_normals.append(Vector3(0, 0, 1));
	

func _make_voxel_face_south(x, y, z) -> void:
	render_mesh_vertices.append(Vector3(x, y, z));
	render_mesh_vertices.append(Vector3(x + voxel_size, y, z));
	render_mesh_vertices.append(Vector3(x + voxel_size, y + voxel_size, z));
	render_mesh_vertices.append(Vector3(x, y + voxel_size, z));
	
	render_mesh_normals.append(Vector3(0, 0, -1));
	render_mesh_normals.append(Vector3(0, 0, -1));
	render_mesh_normals.append(Vector3(0, 0, -1));
	render_mesh_normals.append(Vector3(0, 0, -1));


func _make_voxel_face_east(x, y, z) -> void:
	render_mesh_vertices.append(Vector3(x + voxel_size, y, z));
	render_mesh_vertices.append(Vector3(x + voxel_size, y, z + voxel_size));
	render_mesh_vertices.append(Vector3(x + voxel_size, y + voxel_size, z + voxel_size));
	render_mesh_vertices.append(Vector3(x + voxel_size, y + voxel_size, z));
	
	render_mesh_normals.append(Vector3(1, 0, 0));
	render_mesh_normals.append(Vector3(1, 0, 0));
	render_mesh_normals.append(Vector3(1, 0, 0));
	render_mesh_normals.append(Vector3(1, 0, 0));


func _make_voxel_face_west(x, y, z) -> void:
	render_mesh_vertices.append(Vector3(x, y, z + voxel_size));
	render_mesh_vertices.append(Vector3(x, y, z));
	render_mesh_vertices.append(Vector3(x, y + voxel_size, z));
	render_mesh_vertices.append(Vector3(x, y + voxel_size, z + voxel_size));
	
	render_mesh_normals.append(Vector3(-1, 0, 0));
	render_mesh_normals.append(Vector3(-1, 0, 0));
	render_mesh_normals.append(Vector3(-1, 0, 0));
	render_mesh_normals.append(Vector3(-1, 0, 0));


func _is_in_bound(x, y, z) -> bool:
	if x >= 0 && x < world.CHUNK_SIZE.x:
		if z >= 0 && z < world.CHUNK_SIZE.z:
			if y >= 0 && y < world.CHUNK_SIZE.y:
				return true
	return false


func _is_voxel_at(x, y, z) -> bool:
	if !_is_in_bound(x, y, z):
		return false
	var voxel = voxels_map[x][z][y]
	if voxel == null:
		return false
	return true
