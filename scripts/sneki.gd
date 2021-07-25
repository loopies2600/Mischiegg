extends Enemy

const ATKDURATION := 5.0

var atkTime := rand_range(6, 8)
var dizzyTime := rand_range(2, 3)
var accel := Vector2()

func _ready():
	restoreFromDizziness()
	spinLoop()
	
func _physics_process(_delta):
	velocity += accel
	
	if attacking:
		if $LeftRay.is_colliding():
			accel.x = (SPD / 2)
			
		if $RightRay.is_colliding():
			accel.x = (-SPD / 2)
			
		if $UpRay.is_colliding():
			accel.y = (SPD / 2)
			
		if $DownRay.is_colliding():
			accel.y = (-SPD / 2)
			
		for slide in get_slide_count():
			var col = get_slide_collision(slide).collider
			
			if col is Player:
				if !col.jumping:
					if !col.dead:
						col.takeDamage(2)
			
	else:
		accel *= 0.75
		
		if !jumping:
			velocity *= 0.75
	
func spinLoop():
	if !gotHit:
		atkTime = rand_range(6, 8)
		yield(get_tree().create_timer(atkTime), "timeout")
		attacking = true
		anim.play("Prep")
		yield(anim, "animation_finished")
		anim.play("Attack")
		accel = getDistanceToPlayer().sign() * (SPD / 2)
		yield(get_tree().create_timer(ATKDURATION), "timeout")
		getDizzy()
		spinLoop()
	
func getDizzy():
	attacking = false
	dizzy = true
	velocity = Vector2.ZERO
	anim.play("Dizzy")
	yield(get_tree().create_timer(dizzyTime), "timeout")
	restoreFromDizziness()
	
func restoreFromDizziness():
	anim.play("Idle")
	dizzy = false
	
func kill():
	velocity = Vector2.ZERO
	accel = Vector2.ZERO
	attacking = false
	Globals.player.score += SCORE
	hitbox.set_deferred("disabled", true)
	collisionBox.set_deferred("disabled", true)
	jump()
	velocity.x = SPD / 2
	gotHit = true
	gfx.material.set_shader_param("invertColors", true)
	
func land():
	jumping = false
	
	if gotHit:
		die()

