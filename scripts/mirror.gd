extends Sprite

func _process(_delta):
	get_material().set_shader_param("position", get_canvas_transform().get_origin() * 0.25)
