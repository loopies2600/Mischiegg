extends Area2D

func _ready():
	var _unused = connect("area_entered", self, "_areaEnter")
	
func _areaEnter(area):
	if !owner.eggs:
		var entity = area.owner
		
		if entity is Enemy && !entity.gotHit:
			entity.kill()
