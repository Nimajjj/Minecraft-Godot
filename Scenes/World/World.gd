extends Spatial

const MAP_SIZE = Vector2(5, 5)
const CHUNK_SIZE = Vector3(16, 64, 16)

const MIN_Y = 8

onready var CHUNK = preload("res://Scenes/Chunk/Chunk.tscn")

var chunks = []
var noise = OpenSimplexNoise.new()

func _ready():
	_init_noise()
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
			
			var x_offset = chunk.translation.x 
			var z_offset = chunk.translation.z 
			
			var height = int(noise.get_noise_2d(x + x_offset, z + z_offset) * 100 / 3)
			if height < 0: 
				height *= (-1)
			height += MIN_Y
			var i = 0
			
			for y in range(CHUNK_SIZE.y, -1, -1):
				if y > height: 
					map[x][z].push_front(null)
					continue
					
				if i == 0:
					map[x][z].push_front(VOXELS.VX.GRASS)
					i += 1
				elif i >= 1 && i <= 2:
					map[x][z].push_front(VOXELS.VX.DIRT)
					i += 1
				elif y != 0:
					map[x][z].push_front(VOXELS.VX.STONE)
				elif y == 0:
					map[x][z].push_front(VOXELS.VX.BEDROCK)

				
					
	chunk.voxels_map = map		


func _get_chunk_from_pos(pos) -> MeshInstance:
	var x = floor(pos.x / CHUNK_SIZE.x)
	var z = floor(pos.z / CHUNK_SIZE.z)
	
	if x < 0 || z < 0: return null
	elif x >= len(chunks): return null
	elif z >= len(chunks[x]): return null
	
	return chunks[x][z]
	

func set_voxel_at(collision_pos, voxel) -> void:
	var pos = Vector3(floor(collision_pos.x), floor(collision_pos.y), floor(collision_pos.z))
	
	var chunk = _get_chunk_from_pos(pos)
	if chunk == null:
		return
		
	pos = chunk.global_transform.xform_inv(pos)
	
	chunk.voxels_map[pos.x][pos.z][pos.y] = voxel
	chunk.update()


func _init_noise() -> void:
	randomize()
	noise.seed = randi()
	noise.octaves = 2
	noise.period = 64.0
	noise.persistence = 0.8
