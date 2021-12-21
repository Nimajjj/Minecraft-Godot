extends Node

var _voxel_dictionary = {
	"Bedrock":
		{"transparent":false, "solid":true,
		"texture":Vector2(1, 0)},
	"Stone":
		{"transparent":false, "solid":true,
		"texture":Vector2(2, 0)},
	"Dirt":
		{"transparent":false, "solid":true,
		"texture":Vector2(0, 1)},
	"Grass":
		{"transparent":false, "solid":true,
		"texture":Vector2(0, 1), "texture_TOP":Vector2(2, 1), "texture_BOTTOM":Vector2(0, 1),
		"texture_NORTH":Vector2(1, 1), "texture_SOUTH":Vector2(1, 1), "texture_EAST":Vector2(1, 1), "texture_WEST":Vector2(1, 1)},
}

var _id_voxel_dictionary = {
	0: "Bedrock",
	1: "Stone",
	2: "Dirt",
	3: "Grass",
}

func getVx(id: int) -> Dictionary:
	if _id_voxel_dictionary.has(id):
		return _voxel_dictionary[_id_voxel_dictionary[id]]
	return {}
	
func getVxId(name: String) -> int:
	var id = 0
	for vxName in _id_voxel_dictionary.values():
		if vxName == name:
			return id
		id += 1
	return -1
