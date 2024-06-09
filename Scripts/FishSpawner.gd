class_name FishSpawner
extends Node2D


@export var fish_scene: PackedScene
@onready var player_controller = $"../PlayerController" as PlayerController

var fish_on_screen: Fish = null


# Called when the node enters the scene tree for the first time.
func _ready():
	var timer = Timer.new()
	timer.one_shot = false
	timer.autostart = true
	timer.wait_time = 5.0
	var callable = Callable(self, "spawn_fish")
	timer.connect("timeout", callable)
	add_child(timer)
	

func spawn_fish():
	if player_controller.is_game_over or player_controller.is_resetting:
		return
	if fish_on_screen == null or !is_instance_valid(fish_on_screen):
		fish_on_screen = fish_scene.instantiate() as Fish
		add_child(fish_on_screen)
