extends Area2D

func _ready():
	var _unused = connect("area_entered", self, "_areaEnter")
	
func _areaEnter(area):
	var entity = area.owner
	
	if entity is Player && !entity.hitbox.disabled:
		entity.takeDamage()
		entity.gfx.material.set_shader_param("invertColors", true)
