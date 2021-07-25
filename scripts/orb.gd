extends Sprite

var velocity := Vector2(512, 0)
var angle := 0.0
var scaleFactor := -0.0125

func _ready():
	velocity = velocity.rotated(deg2rad(angle))
	
func _physics_process(delta):
	scale += Vector2(scaleFactor, scaleFactor)
	position += velocity * delta
