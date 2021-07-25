extends Sprite

var velocity := Vector2()

onready var life := rand_range(1.0, 4.0)
onready var initialLife := life
onready var velocityRange := rand_range(-256, 256)
onready var gravityRange := rand_range(-256, 256)

func _ready():
	velocity = Vector2(velocityRange, gravityRange)
	
func _process(delta):
	life -= delta
	
	scale.x = Math.remapToRange(life, 0, initialLife, 0, 1)
	scale.y = Math.remapToRange(life, 0, initialLife, 0, 1)
	
	if life <= 0:
		queue_free()
	
func _physics_process(delta):
	velocity.y += abs(gravityRange) * delta
	position += velocity * delta
