extends Enemy

const ATKDURATION := 1

var atkTime := rand_range(6, 8)

func _ready():
	atkLoop()
	
func atkLoop():
	if !gotHit:
		atkTime = rand_range(6, 8)
		yield(get_tree().create_timer(atkTime), "timeout")
		attacking = true
		anim.play("Prep")
		yield(anim, "animation_finished")
		anim.play("Attack")
		spawnAcorns()
		yield(get_tree().create_timer(ATKDURATION), "timeout")
		anim.play("Idle")
		atkLoop()
	
func spawnAcorns():
	if !gotHit:
		var acorn = load("res://scenes/acorn.tscn")
		var acorn1 = acorn.instance()
		var acorn2 = acorn.instance()
		var acorn3 = acorn.instance()
		
		acorn1.global_position = $Position2D.global_position
		acorn2.global_position = $Position2D2.global_position
		acorn3.global_position = $Position2D3.global_position
		
		acorn1.velocity = Vector2(-512, 0)
		acorn2.velocity = Vector2(-384, -256)
		acorn3.velocity = Vector2(-128, -512)
		
		get_tree().get_root().add_child(acorn1)
		get_tree().get_root().add_child(acorn2)
		get_tree().get_root().add_child(acorn3)
		
func kill():
	velocity = Vector2.ZERO
	attacking = false
	Globals.player.score += SCORE
	hitbox.set_deferred("disabled", true)
	collisionBox.set_deferred("disabled", true)
	jump()
	velocity.x = SPD / 2
	gotHit = true
	gfx.material.set_shader_param("invertColors", true)
