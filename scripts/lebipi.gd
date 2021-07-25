extends Area2D

var hasBomb := true
var velocity := Vector2(0, 0)
var target = null
var detectionLength := 512

func _ready():
	$Shadow.set_as_toplevel(true)
	var _unused = connect("area_entered", self, "_activate")
	
func _activate(area):
	if area.owner is Player:
		velocity.x = -1024
	
func _physics_process(delta):
	$Shadow.global_position = Vector2(global_position.x + 32, Globals.player.global_position.y)
	
	if hasBomb:
		var spaceState = get_world_2d().direct_space_state
		var result = spaceState.intersect_ray(position, position + Vector2(0, detectionLength), [self], collision_mask)
		
		if result:
			if result.collider is Player:
				target = result.collider
				dropBomb()
		
		$Animator.play("Hover")
	else:
		$Animator.play("NoBomb")
		
	position += velocity * delta
	
func dropBomb():
	hasBomb = false
	var bomb = load("res://scenes/bomb.tscn").instance()
	bomb.global_position = Vector2($GFX/Bomb.global_position.x, target.global_position.y + 64)
	bomb.height = (target.global_position.y + 64) - $GFX/Bomb.global_position.y
	get_tree().get_root().add_child(bomb)
