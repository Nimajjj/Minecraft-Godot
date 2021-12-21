extends Spatial

const MAP_SIZE = Vector2(4, 4)
const CHUNK_SIZE = Vector3(16, 64, 16)

onready var CHUNK = preload("res://Scenes/Chunk/Chunk.tscn")

var chunks = []

func _ready():
	_init_chunks()
	_make_world()
	
	$Debug3DCharacter.world = self


func _make_world() -> void:
	for chunks_range in chunks:
		for chunk in chunks_range:
			add_child(chunk)


func _init_chunks() -> void:
	for x in range(0, MAP_SIZE.x):
		chunks.append([])
		for z in range(0, MAP_SIZE.y):
			var chunk = CHUNK.instance()
			chunk.world = self
			chunk.global_translate(Vector3(x * CHUNK_SIZE.x, 0, z * CHUNK_SIZE.z))
			chunks[x].append(chunk)
			_init_chunk_terrain(chunk)
	
	
func _init_chunk_terrain(chunk) -> void:
	var map = []
	for x in range(0, CHUNK_SIZE.x):
		map.append([])
		for z in range(0, CHUNK_SIZE.z):
			map[x].append([])
			for y in range(0, CHUNK_SIZE.y):
				if y == 0:
					map[x][z].append(VxDict.getVxId("Bedrock"))
				elif y >= 1 && y <= 3:
					map[x][z].append(VxDict.getVxId("Stone"))
				elif y >= 4 && y <= 5:
					map[x][z].append(VxDict.getVxId("Dirt"))
				elif y == 6:
					map[x][z].append(VxDict.getVxId("Grass"))
				else:
					map[x][z].append(null)
					
	chunk.voxels_map = map		


func _get_chunk_from_pos(pos):
	var x = floor(pos.x / CHUNK_SIZE.x)
	var z = floor(pos.z / CHUNK_SIZE.z)
	
	if x < 0 || z < 0: return null
	elif x >= len(chunks): return null
	elif z >= len(chunks[x]): return null
	
	return chunks[x][z]
	

func set_voxel_at(collision_pos, voxel) -> void:
	var pos = Vector3(floor(collision_pos.x), floor(collision_pos.y), floor(collision_pos.z))
	
	var chunk = _get_chunk_from_pos(pos)
	if chunk == null: return
		
	pos = chunk.global_transform.xform_inv(pos)
	
	chunk.voxels_map[pos.x][pos.z][pos.y] = voxel
	chunk.update()
