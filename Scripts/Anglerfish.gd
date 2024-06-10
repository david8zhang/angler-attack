class_name Anglerfish
extends Node2D

@onready var sprite = $Sprite2D as Sprite2D

func update_texture(path: String):
	sprite.texture = load(path)
