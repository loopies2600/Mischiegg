extends Node2D

var canPress := false

func _ready():
	yield($Animator, "animation_finished")
	canPress = true
	
func _input(event):
	if event.is_action_pressed("start"):
		if canPress:
			gameStart()
			
func gameStart():
	$Animator.play("Fade")
	canPress = false
	yield($Animator, "animation_finished")
	Globals.get_node("TitleMusic").queue_free()
	get_tree().change_scene("res://scenes/stage/city.tscn")
