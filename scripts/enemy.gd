extends KinematicBody2D
class_name Enemy

const ATKTIME := 0.5
const GRAV := 800
const JMP := 300
const SPD := 196.0
const SCORE := 200

var dizzy := false
var attacking := false
var gotHit := false
var vsp := 0.0
var velocity := Vector2()
var jumping := false
var height := 0.0
var prevPos := Vector2()

onready var hitbox = $GFX/HitArea/Hitbox
onready var collisionBox = $CollisionBox
onready var gfx = $GFX
onready var anim = $Animator
onready var visibility = $VisibilityEnabler2D

func _ready():
	set_process(false)
	set_physics_process(false)
	collisionBox.disabled = true
	hitbox.disabled = true
	var _unused = visibility.connect("screen_entered", self, "_onScreenEnter")
	
	gfx.add_to_group("Invertables")
	gfx.material = gfx.material.duplicate()
	disableColorInvert()
	
func _onScreenEnter():
	collisionBox.disabled = false
	hitbox.disabled = false
	
	
func disableColorInvert():
	if !Globals.player.awaitRevival:
		yield(get_tree().create_timer(0.1), "timeout")
		gfx.material.set_shader_param("invertColors", false)
		disableColorInvert()
	
func getUnstuck():
	if getPosInScreen().x < 16:
		global_position.x = prevPos.x
		
	if getPosInScreen().y > 480 || getPosInScreen().y < 256:
		global_position.y = prevPos.y
			
func _physics_process(delta):
	prevPos = global_position
	z_index = getPosInScreen().y
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	height += vsp * delta
	height = max(0, height)
	
	if height > 0:
		vsp -= GRAV * delta
	else:
		land()
		
	if !attacking:
		if !dizzy:
			if !velocity:
				anim.play("Idle")
		
	if gotHit:
		anim.play("Die")
		
	gfx.position.y = -height
	getUnstuck()
	
func jump(jmp := JMP):
	vsp = jmp
	jumping = true
	
func land():
	jumping = false
	
	if gotHit:
		die()
		
func die():
	Globals.player.kills += 1
	var explosion = load("res://scenes/explosionbasic.tscn").instance()
	explosion.global_position = global_position
	get_tree().get_root().add_child(explosion)
	queue_free()
	
func kill():
	die()
	
func getPosInScreen(node = self):
	return node.get_global_transform_with_canvas().get_origin()
	
func getDistanceToPlayer():
	return Globals.player.global_position - global_position
