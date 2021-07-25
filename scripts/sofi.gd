extends Enemy

const ATKDURATION := 1.25

var atkTime := rand_range(4, 5)

func _ready():
	spinLoop()
	
func spinLoop():
	if !gotHit:
		atkTime = rand_range(4, 5)
		yield(get_tree().create_timer(atkTime), "timeout")
		attacking = true
		anim.play("Prep")
		yield(anim, "animation_finished")
		anim.play("Attack")
		yield(get_tree().create_timer(ATKDURATION), "timeout")
		anim.play("Idle")
		spinLoop()
	
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
