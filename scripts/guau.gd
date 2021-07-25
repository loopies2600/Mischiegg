extends Enemy

var barkTime := rand_range(3, 4)

func _ready():
	barkLoop()
	
func barkLoop():
	if !gotHit:
		barkTime = rand_range(3, 4)
		yield(get_tree().create_timer(barkTime), "timeout")
		velocity.x = -SPD / 4
		velocity.y = rand_range(-SPD / 4, SPD / 4)
		jump()
		attacking = true
		anim.play("Prep")
		yield(anim, "animation_finished")
		anim.play("Bark")
		spawnSonicWave()
		barkLoop()
		
func spawnSonicWave():
	if !gotHit:
		var wave = load("res://scenes/sonicwave.tscn").instance()
		wave.global_position = gfx.global_position
		get_tree().get_root().add_child(wave)
		wave.shadow.set_as_toplevel(true)
		wave.shadow.global_position.y = $Shadow.global_position.y
	
func kill():
	Globals.player.score += SCORE
	hitbox.set_deferred("disabled", true)
	collisionBox.set_deferred("disabled", true)
	jump()
	velocity.x = SPD / 2
	gotHit = true
	gfx.material.set_shader_param("invertColors", true)
	
func land():
	jumping = false
	attacking = false
	velocity = Vector2.ZERO
	
	if gotHit:
		die()

