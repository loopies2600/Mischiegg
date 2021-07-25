extends Node

onready var hud = preload("res://scenes/hud/mainhud.tscn")

func _ready():
	Globals.stageAnim = $Stage/Anim
	add_child(hud.instance())
	
func invertColors(booly):
	for invertable in get_tree().get_nodes_in_group("Invertables"):
		invertable.material.set_shader_param("invertColors", booly)
