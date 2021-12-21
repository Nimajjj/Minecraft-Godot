extends Spatial

const MAP_SIZE = Vector2(8, 8)
const CHUNK_SIZE = Vector3(16, 64, 16)

onready var CHUNK = preload("res://Scenes/Chunk/Chunk.tscn")

var chunks_map = {}

func _ready():
	_init_chunk_map()
	_init_terrain()
	_make_world()
	
	$Debug3DCharacter.world = self


func _make_world():
	for chunk in chunks_map.keys():
		add_child(chunk)


func _init_terrain():
	for chunk in chunks_map.keys():
		for x in range(0, 16):
			chunks_map[chunk].append([])
			for z in range(0, 16):
				chunks_map[chunk][x].append([])
				for y in range(0, 64):
					if y == 0:
						chunks_map[chunk][x][z].append(VxDict.getVxId("Bedrock"))
					elif y >= 1 && y <= 3:
						chunks_map[chunk][x][z].append(VxDict.getVxId("Stone"))
					elif y >= 4 && y <= 5:
						chunks_map[chunk][x][z].append(VxDict.getVxId("Dirt"))
					elif y == 6:
						chunks_map[chunk][x][z].append(VxDict.getVxId("Grass"))
					else:
						chunks_map[chunk][x][z].append(null)


func _init_chunk_map():
	for x in range(0, MAP_SIZE.x):
		chunks.append([])
		for z in range(0, MAP_SIZE.y):
			var chunk = CHUNK.instance()
			chunk.world = self
			chunk.global_translate(Vector3(x * CHUNK_SIZE.x, 0, z * CHUNK_SIZE.z))
			chunks_map[chunk] = []
			

func _get_chunk_from_pos(pos):
	for chunk in chunks_map.keys():
		var chunk_pos = chunk.translation
		if pos.x >= chunk_pos.x && pos.x < chunk_pos.x + CHUNK_SIZE.x:
			if pos.z >= 0 && pos.z < chunk_pos.z + CHUNK_SIZE.z:
				if pos.y >= 0 && pos.y < chunk_pos.y + CHUNK_SIZE.y:
					return chunk
	return null
		

func set_voxel_at(collision_pos, voxel):
	var pos = Vector3()
	pos.x = floor(collision_pos.x)
	pos.y = floor(collision_pos.y)
	pos.z = floor(collision_pos.z)
	
	var chunk = _get_chunk_from_pos(pos)
	if chunk == null:
		print("out of map")
		return
		
	pos = chunk.global_transform.xform_inv(pos)
	
	chunks_map[chunk][pos.x][pos.z][pos.y] = voxel
	chunk.update()
