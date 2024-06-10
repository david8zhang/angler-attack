class_name FishSpawner
extends Node2D

@export var fish_scene: PackedScene
@export var shark_scene: PackedScene
@onready var player_controller = $"../PlayerController" as PlayerController

var fish_on_screen: Fish = null
var shark_on_screen: Shark = null


# Called when the node enters the scene tree for the first time.
func _ready():
	var timer = Timer.new()
	timer.one_shot = false
	timer.autostart = true
	timer.wait_time = 3.0
	var spawn_fish_callable = Callable(self, "spawn_fish")
	timer.connect("timeout", spawn_fish_callable)
	add_child(timer)
	
	var shark_spawn_timer = Timer.new()
	shark_spawn_timer.one_shot = false
	shark_spawn_timer.autostart = true
	shark_spawn_timer.wait_time = 20.0
	var spawn_shark_callable = Callable(self, "handle_shark_spawn")
	shark_spawn_timer.connect("timeout", spawn_shark_callable)
	add_child(shark_spawn_timer)


func spawn_fish():
	print("spawning fish...")
	if player_controller.is_game_over or player_controller.is_resetting or player_controller.is_eating:
		return
	else:
		if !player_controller.is_light_off():
			var brightness = player_controller.get_light_brightness()
			if brightness == Light.Brightness.HIGH:
				init_fish_type(Fish.FishTypes.LARGE)
			else:
				init_fish_type(Fish.FishTypes.SMALL)


func init_fish_type(fish_type: Fish.FishTypes):
	if fish_on_screen == null or !is_instance_valid(fish_on_screen):
		fish_on_screen = fish_scene.instantiate() as Fish
		add_child(fish_on_screen)
		fish_on_screen.init(fish_type)


func handle_shark_spawn():
	if !player_controller.is_light_off():
		var brightness = player_controller.get_light_brightness()
		var rand_num = randi_range(1, 100)
		var threshold = 25 if brightness == Light.Brightness.LOW else 50
		if rand_num <= threshold:
			if shark_on_screen == null or !is_instance_valid(shark_on_screen):
				shark_on_screen = shark_scene.instantiate() as Shark
				add_child(shark_on_screen)
