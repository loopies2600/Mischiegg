extends Node2D

func _ready():
	var music = load("res://scenes/stage/titlemusic.tscn").instance()
	Globals.add_child(music)
	
	var _unused = $Animator.connect("animation_finished", self, "_animEnd")
	
func _animEnd(_anim):
	get_tree().change_scene("res://scenes/stage/titlescreen.tscn")
