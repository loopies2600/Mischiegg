extends Node2D

var orb = load("res://scenes/orb.tscn")
var exploded := false

func _ready():
	var _unused = $Boom.connect("finished", $Boom, "queue_free")
	#Globals.stageAnim.play("Shake1")
	spawnOrbs()
	
func spawnOrbs(amt := 16):
	var core = orb.instance()
	core.velocity = Vector2()
	core.scale = Math.toVec2(2.0)
	core.scaleFactor = 0.05
	add_child(core)
		
	var calculatedAngle = 360.0 / amt
	
	for i in range(amt):
		var newOrb = orb.instance()
		newOrb.angle = calculatedAngle * i
		add_child(newOrb)
		
	exploded = true
		
func _process(_delta):
	if !get_child_count() && exploded:
		queue_free()
