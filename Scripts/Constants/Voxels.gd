extends Node


const _DICT = {
	-1: {"transparent":false, "solid":true,
		"texture":Vector2(0, 0)},
	0:
		{"transparent":false, "solid":true,
		"texture":Vector2(1, 0)},
	1:
		{"transparent":false, "solid":true,
		"texture":Vector2(2, 0)},
	2:
		{"transparent":false, "solid":true,
		"texture":Vector2(0, 1)},
	3:
		{"transparent":false, "solid":true,
		"texture":Vector2(0, 1), "texture_TOP":Vector2(2, 1), "texture_BOTTOM":Vector2(0, 1),
		"texture_NORTH":Vector2(1, 1), "texture_SOUTH":Vector2(1, 1), "texture_EAST":Vector2(1, 1), "texture_WEST":Vector2(1, 1)},
}


enum VX {
	BEDROCK,
	STONE,
	DIRT,
	GRASS
}


func get_vx(voxel: int) -> int:
	return _DICT[voxel] if _DICT.has(voxel) else -1
