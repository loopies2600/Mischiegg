extends Node2D

export (int) var offset := 0

func _process(delta):
	z_index = get_global_transform_with_canvas().get_origin().y + offset
