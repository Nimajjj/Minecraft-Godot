extends MeshInstance

const CUBE_SIZE: int = 2

var quad_vertices = []
var quad_indices = []
var quad_uvs = []
var quad_to_index_vertices = {}


var cube_texture = Texture.new()


func _ready():
	var uv_map = Vector4.new()
	uv_map.init(0, 0, 1, 1)
	
	make_cube(Vector3(CUBE_SIZE * 0, CUBE_SIZE * 0, 0), uv_map)


func make_cube(pos: Vector3, uv_map: Vector4) -> void :
	var result_mesh = Mesh.new()
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var vert_north_bottom_left = 	Vector3(-CUBE_SIZE/2 + pos.x, CUBE_SIZE/2 + pos.y, -CUBE_SIZE/2 + pos.z)
	var vert_north_bottom_right = 	Vector3(CUBE_SIZE/2 + pos.x, CUBE_SIZE/2 + pos.y, -CUBE_SIZE/2 + pos.z)
	var vert_north_top_left = 		Vector3(-CUBE_SIZE/2 + pos.x, CUBE_SIZE/2 + pos.y, CUBE_SIZE/2 + pos.z)
	var vert_north_top_right = 		Vector3(CUBE_SIZE/2 + pos.x, CUBE_SIZE/2 + pos.y, CUBE_SIZE/2 + pos.z)
	
	var vert_south_bottom_left = 	Vector3(-CUBE_SIZE/2 + pos.x, -CUBE_SIZE/2 + pos.y, -CUBE_SIZE/2 + pos.z)
	var vert_south_bottom_right = 	Vector3(CUBE_SIZE/2 + pos.x, -CUBE_SIZE/2 + pos.y, -CUBE_SIZE/2 + pos.z)
	var vert_south_top_left = 		Vector3(-CUBE_SIZE/2 + pos.x, -CUBE_SIZE/2 + pos.y, CUBE_SIZE/2 + pos.z)
	var vert_south_top_right = 		Vector3(CUBE_SIZE/2 + pos.x, -CUBE_SIZE/2 + pos.y, CUBE_SIZE/2 + pos.z)
	
	# make the 6 quads:
	add_quad(vert_south_top_right, vert_south_top_left, vert_south_bottom_left, vert_south_bottom_right, uv_map); # B
	add_quad(vert_north_top_right, vert_north_bottom_right, vert_north_bottom_left, vert_north_top_left, uv_map); # A

	add_quad(vert_north_bottom_left, vert_north_bottom_right, vert_south_bottom_right, vert_south_bottom_left, uv_map); # F
	add_quad(vert_north_top_left, vert_south_top_left, vert_south_top_right, vert_north_top_right, uv_map); # E

	add_quad(vert_north_top_right, vert_south_top_right, vert_south_bottom_right, vert_north_bottom_right, uv_map); # C
	add_quad(vert_north_top_left, vert_north_bottom_left, vert_south_bottom_left, vert_south_top_left, uv_map); # D
	
	
	
	var i = 0
	for vertex in quad_vertices:
		surface_tool.add_uv(quad_uvs[i])
		surface_tool.add_vertex(vertex);
		i += 1
	for index in quad_indices:
		surface_tool.add_index(index);
	
	surface_tool.generate_normals();
	
	result_mesh = surface_tool.commit();
	self.mesh = result_mesh;


	# add quad and indice to respectives array
func add_quad(pt1: Vector3, pt2: Vector3, pt3: Vector3, pt4: Vector3, uv_map: Vector4) -> void:
	var x = min(uv_map.x, uv_map.w)
	var y = min(uv_map.y, uv_map.h)
	var w = max(uv_map.x, uv_map.w)
	var h = max(uv_map.y, uv_map.h)

	
	var uv = Vector2(w, y)
	var index_one: int = _add_or_get_vertex_index(pt1, uv)
	
	uv = Vector2(x, y)
	var index_two: int = _add_or_get_vertex_index(pt2, uv)

	uv = Vector2(x, h)
	var index_three: int = _add_or_get_vertex_index(pt3, uv)

	uv = Vector2(w, h)
	var index_foor: int = _add_or_get_vertex_index(pt4, uv)
	
	quad_indices.append(index_one)
	quad_indices.append(index_two)
	quad_indices.append(index_three)
	
	quad_indices.append(index_one)
	quad_indices.append(index_three)
	quad_indices.append(index_foor)


	# return vertex's index 
func _add_or_get_vertex_index(vertex, uv) -> int:
	if quad_to_index_vertices.has(vertex):
		return quad_to_index_vertices[vertex];
	
	else:
		quad_uvs.append(uv)
		quad_vertices.append(vertex);
		quad_to_index_vertices[vertex] = quad_vertices.size() - 1;
		return quad_vertices.size() - 1;



