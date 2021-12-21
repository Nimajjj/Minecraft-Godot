extends Label


func _process(delta):
	text = str(Engine.get_frames_per_second()) + " FPS"
	var pos = get_parent().get_parent().translation
	text += "\nx: {0}, y: {1}, z: {2}".format([str(pos.x).pad_decimals(2), str(pos.y).pad_decimals(2), str(pos.z).pad_decimals(2)])
