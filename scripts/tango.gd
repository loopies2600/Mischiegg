extends KinematicBody2D
class_name Player

const ATKTIME := 0.5
const GRAV := 400
const JMP := 300
const SPD := 150.0
const MAXHP := 5
const MAXLIVES := 3
const MAXEGGS := 64
const PONGSPEED := 2048.0
const PONGTIME := 4.0
const DIZZYTIME := 3.43
const NUKETIME := 0.3
const GRACETIME := 4.0

export (bool) var cooldown = true

onready var gfx = $GFX
onready var anim = $Animator
onready var hitbox = $GFX/Hitbox/CollisionShape2D
onready var collisionBox = $CollisionBox

var awaitRevival := false
var dead := false
var pongMode := false
var dizzy := false
var attacking := false
var canInput := true
var jumping := false
var gracePeriod := false
var win := false
var height = 0
var vsp = 0
var elevMult = 1.0
var fallMult = 3.0
var lives := MAXLIVES setget _setLives
var health := MAXHP setget _setHealth
var eggs := MAXEGGS setget _setEggs
var kills := 0
var score := 0 setget _setScore
var bounces := 0
var nuke := false
var prevPos := Vector2()

var velocity := Vector2()
var pongModeVector := Vector2(PONGSPEED, PONGSPEED)
var pongTime := PONGTIME

func _setLives(value : int):
	if lives > MAXLIVES:
		lives = MAXLIVES
		return
		
	lives = value
	
func _setHealth(value : int):
	if health > MAXHP:
		health = MAXHP
		return
		
	health = value
	
func _setScore(value : int):
	if score > 99999999:
		return
		
	score = value
	
func _setEggs(value : int):
	if eggs > MAXEGGS:
		eggs = MAXEGGS
		
	if eggs < 0:
		return
		
	eggs = value
	
func _ready():
	Globals.player = self
	nukeLoop()
	disableColorInvert()
	
func disableColorInvert():
	if Engine.time_scale == 1.0:
		yield(get_tree().create_timer(0.1), "timeout")
		gfx.material.set_shader_param("invertColors", false)
		disableColorInvert()
	
func nukeLoop():
	if nuke:
		var explosion = load("res://scenes/explosionbasic.tscn").instance()
		explosion.global_position = global_position - Vector2(0, height)
		get_tree().get_root().add_child(explosion)
	yield(get_tree().create_timer(NUKETIME), "timeout")
	nukeLoop()
	
func jump(jmp := JMP):
	vsp = jmp
	jumping = true
	
func land():
	$Camera.current = true
	jumping = false
	if !attacking && !win:
		canInput = true
	
	if !gracePeriod && !win:
		hitbox.set_deferred("disabled", false)
		collisionBox.set_deferred("disabled", false)
	
	if awaitRevival:
		getDizzy()
	if health < 0 && lives < 0:
		dieForReal()
	
func getUnstuck():
	if !pongMode:
		if getPosInScreen().x < 6:
			global_position.x = prevPos.x
			
		if getPosInScreen().y > 475 || getPosInScreen().y < 256:
			global_position.y = prevPos.y
		
func _physics_process(delta):
	if gracePeriod:
		visible = !visible
	else:
		visible = true
	
	prevPos = global_position
	z_index = getPosInScreen().y
	
	if !dead:
		if canInput:
			velocity = getInputDirection().normalized() * SPD
		if pongMode:
			pongTime -= delta
			if getPosInScreen().x > 1024:
				$Boing.play()
				$Boing.pitch_scale = rand_range(0.9, 1.1)
				Globals.stageAnim.play("Shake1")
				pongModeVector.x = -PONGSPEED
				bounces += 1
				
			if getPosInScreen().x < 0:
				$Boing.play()
				$Boing.pitch_scale = rand_range(0.9, 1.1)
				Globals.stageAnim.play("Shake1")
				pongModeVector.x = PONGSPEED
				bounces += 1
				
			if getPosInScreen(gfx).y < 0:
				$Boing.play()
				$Boing.pitch_scale = rand_range(0.9, 1.1)
				Globals.stageAnim.play("Shake0")
				vsp = -PONGSPEED
				bounces += 1
				
			if height < 1:
				$Boing.play()
				$Boing.pitch_scale = rand_range(0.9, 1.1)
				Globals.stageAnim.play("Shake0")
				vsp = PONGSPEED
				bounces += 1
				
			velocity.x = pongModeVector.x
			gfx.rotation = Vector2(velocity.x, height).normalized().angle() + deg2rad(90)
			
			if pongTime < 0:
				restoreFromPong()
				
		velocity = move_and_slide(velocity, Vector2.UP)
		
		if eggs:
			$GFX/Egg.modulate.a = 1.0
		else:
			$GFX/Egg.modulate.a = 0.0
			
		if !dizzy:
			if !jumping:
				if !attacking:
					if !pongMode:
						if !win:
							if velocity:
								anim.play("Walk")
							else:
								anim.play("Idle")
		if !attacking:
			if canInput:
				if Input.is_action_just_pressed("attack"):
					attack()
					
		height += vsp * delta
		height = max(0, height)
		
		if !dizzy:
			if !pongMode:
				if height > 0:
					vsp -= GRAV * delta * (elevMult if sign(vsp) == 1 else fallMult)
				else:
					land()
			
		gfx.position.y = -height
		
	getUnstuck()
	
func takeDamage(damage := 1):
	var explosion = load("res://scenes/explosionbasic.tscn").instance()
	explosion.global_position = global_position - Vector2(0, height)
	get_tree().get_root().add_child(explosion)
	$Camera.current = false
	canInput = false
	self.health -= damage
	
	if health < 0:
		getPongy()
	else:
		attacking = false
		jumping = false
		hitbox.set_deferred("disabled", true)
		collisionBox.set_deferred("disabled", true)
		anim.play("Hurt")
		velocity.x = -SPD / 2
		jump(JMP)
		startGracePeriod()
	
func startGracePeriod():
	gracePeriod = true
	hitbox.set_deferred("disabled", true)
	collisionBox.set_deferred("disabled", true)
	yield(get_tree().create_timer(GRACETIME), "timeout")
	hitbox.set_deferred("disabled", false)
	collisionBox.set_deferred("disabled", false)
	gracePeriod = false
	
func getDizzy(damage := 0):
	$Birds.play()
	canInput = false
	dizzy = true
	self.health -= damage
	attacking = false
	jumping = false
	hitbox.set_deferred("disabled", true)
	collisionBox.set_deferred("disabled", true)
	anim.play("Dizzy")
	velocity.x = 0
	restoreFromDizzyness()
	
func restoreFromDizzyness():
	yield(get_tree().create_timer(DIZZYTIME), "timeout")
	dizzy = false
	awaitRevival = false
	startGracePeriod()
	
func getPongy():
	if !win:
		if !pongMode:
			pongMode = true
			velocity = Vector2.ZERO
			$Camera.current = false
			self.lives -= 1
			
			if lives < 0:
				nuke = true
				
			vsp = PONGSPEED
			bounces = 0
			canInput = false
			attacking = false
			jumping = false
			hitbox.set_deferred("disabled", true)
			collisionBox.set_deferred("disabled", true)
			anim.play("Pong")
	
func restoreFromPong():
	if lives < 0:
		awaitRevival = false
		Engine.time_scale = 0.5
		Globals.stageAnim.play("Flash")
		Globals.hud.queue_free()
		$BigBoing.play()
		nuke = false
		Globals.stageMusic.fade = true
	else:
		awaitRevival = true
		health = MAXHP
		
	gfx.rotation = 0
	pongTime = PONGTIME
	rotation = 0
	pongMode = false
	anim.play("Hurt")
	velocity = Vector2()
	velocity.x = (-SPD / 2) * sign(pongModeVector.x)
	jump()
	
func dieForReal():
	$Crash.play()
	$Camera.current = false
	Engine.time_scale = 1
	anim.play("Dead")
	dead = true
	yield(get_tree().create_timer(PONGTIME), "timeout")
	add_child(load("res://scenes/hud/retryscr.tscn").instance())
	
func setWinState():
	if !win:
		velocity = Vector2.ZERO
		for entity in get_tree().get_nodes_in_group("Enemy"):
			entity.kill()
			
		win = true
		canInput = false
		anim.play("Win")
		hitbox.set_deferred("disabled", true)
		collisionBox.set_deferred("disabled", true)
		Globals.stageAnim.play("FadeOut")
		Globals.hud.queue_free()
		Globals.stageMusic.fade = true
		yield(get_tree().create_timer(PONGTIME), "timeout")
		add_child(load("res://scenes/hud/winscr.tscn").instance())
	
func attack():
	if !win:
		velocity *= 0.25
		attacking = true
		canInput = false
		
		if cooldown:
			if attacking:
				anim.play("Prep")
			yield(get_tree().create_timer(ATKTIME * 0.25), "timeout")
			if attacking:
				anim.play("Throw")
			spawnEgg()
			yield(get_tree().create_timer(ATKTIME * 0.5), "timeout")
			if attacking:
				canInput = true
				attacking = false
		else:
			if attacking:
				anim.play("Throw")
			spawnEgg()
			yield(get_tree().create_timer(ATKTIME * 0.25), "timeout")
			if attacking:
				canInput = true
				attacking = false
	
func spawnEgg():
	if eggs:
		$EggPop.play()
		$EggPop.pitch_scale = rand_range(0.75, 1.25)
		
		var egg = load("res://scenes/egg.tscn").instance()
		egg.global_position = gfx.global_position + Vector2(64, 16)
		get_tree().get_root().add_child(egg)
		egg.shadow.set_as_toplevel(true)
		egg.shadow.global_position.y = $Shadow.global_position.y
		self.eggs -= 1
	
func meeleeAttack():
	if !eggs:
		$HurtBox.set_deferred("monitorable", true)
		$HurtBox.set_deferred("monitoring", true)
		$HurtBox/Area.set_deferred("disabled", false)
		
	yield(get_tree().create_timer(0.1), "timeout")
	$HurtBox.set_deferred("monitorable", false)
	$HurtBox.set_deferred("monitoring", false)
	$HurtBox/Area.set_deferred("disabled", true)
		
func getInputDirection():
	return Vector2(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"), Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"))
	
func getPosInScreen(node = self):
	return node.get_global_transform_with_canvas().get_origin()
