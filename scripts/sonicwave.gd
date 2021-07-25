extends Area2D

var velocity := Vector2(0, 0)
var accel := 16.0

onready var shadow = $Shadow

func _ready():
	var _unused = connect("area_entered", self, "_areaEnter")
	_unused = $VisibilityNotifier2D.connect("screen_exited", self, "queue_free")
	
func _areaEnter(area):
	var entity = area.owner
	
	if entity is Player && !entity.hitbox.disabled:
		entity.takeDamage()
		entity.gfx.material.set_shader_param("invertColors", true)
		kill()
		
func _physics_process(delta):
	velocity.x -= accel
	z_index = getPosInScreen().y
	
	shadow.global_position.x = global_position.x
	position += velocity * delta
	
func kill():
	queue_free()
	
func getPosInScreen(node = self):
	return node.get_global_transform_with_canvas().get_origin()
