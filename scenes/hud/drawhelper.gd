extends Node2D

onready var heart = load("res://sprites/hud/heart.tres")
onready var tanguito = load("res://sprites/hud/tanguito.tres")
onready var egg = load("res://sprites/hud/egg.tres")
onready var skull = load("res://sprites/hud/skull.tres")

func _process(_delta):
	update()
	
func _draw():
	if Globals.player:
		for i in range(Globals.player.lives):
			draw_texture(tanguito, Vector2(16, 8) + Vector2(48 * i, 0))
			
		for i in range(Globals.player.health):
			draw_texture(heart, Vector2(16, 48) + Vector2(48 * i, 0))
			
		draw_texture(egg, Vector2(16, 96))
		draw_texture(skull, Vector2(128, 96))
