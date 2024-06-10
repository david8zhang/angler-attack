extends Node2D

func _unhandled_input(event):
	if Input.is_action_just_pressed("play"):
		get_tree().change_scene_to_file("res://Scenes/Main.tscn")
