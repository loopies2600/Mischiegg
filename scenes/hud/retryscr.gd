extends CanvasLayer

func _input(event):
	if event.is_action_pressed("retry"):
		restart()
	if event.is_action_pressed("exit"):
		get_tree().quit()

func restart():
	$Animator.play("FadeOut")
	yield($Animator, "animation_finished")
	get_tree().change_scene("res://scenes/stage/city.tscn")
