extends Area2D

var velocity := Vector2(1024, 0)

onready var shadow = $Shadow

func _ready():
	var _unused = connect("area_entered", self, "_areaEnter")
	_unused = $VisibilityNotifier2D.connect("screen_exited", self, "queue_free")
	
func _areaEnter(area):
	var entity = area.owner
	
	if entity is Enemy && !entity.gotHit:
		entity.kill()
		kill()
		
func _physics_process(delta):
	z_index = getPosInScreen().y
	
	shadow.global_position.x = global_position.x
	position += velocity * delta
	
func kill():
	for _i in range(8):
		var piece = load("res://scenes/piece.tscn").instance()
		piece.global_position = global_position
		get_tree().get_root().add_child(piece)
		
	queue_free()
	
func getPosInScreen(node = self):
	return node.get_global_transform_with_canvas().get_origin()
