extends StaticBody2D

func _process(_delta):
	position = -get_canvas_transform().get_origin()
