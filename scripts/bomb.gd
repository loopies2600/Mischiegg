extends Node2D

const GRAV := 1200.0

var instant := false
var height := 0.0
var vsp := 0.0
var bounces := 0
var accum := 0.0
var target = null
var firstBounce := true

onready var gfx = $GFX

func _ready():
	var _unused = $Timer.connect("timeout", self, "_onTimeout")
	_unused = connect("area_entered", self, "_onAreaEnter")
	_unused = connect("area_exited", self, "_onAreaExit")
	
func _onAreaEnter(area):
	if area.owner is Player:
		target = area.owner
		
func _onAreaExit(area):
	if area.owner is Player:
		target = null
		
func _physics_process(delta):
	z_index = getPosInScreen().y
	$DamageArea.position.y = -height
	
	$Tick.pitch_scale = 3 / $Timer.time_left
	$AnimationPlayer.playback_speed = 3 / $Timer.time_left
		
	height += vsp * delta
	height = max(0.0, height)
	
	if height > 0:
		vsp -= GRAV * delta
		accum += GRAV * delta
	else:
		if firstBounce:
			vsp = 0
			firstBounce = false
			
		vsp += accum * 0.9
		accum = 0
		
	gfx.position.y = -height
	
func _onTimeout():
	if target:
		target.takeDamage(4)
		
	var explosion = load("res://scenes/explosionbasic.tscn").instance()
	explosion.global_position = global_position - Vector2(0, height)
	get_tree().get_root().add_child(explosion)
	queue_free()
	
func getPosInScreen(node = self):
	return node.get_global_transform_with_canvas().get_origin()
