class_name PlayerController
extends Node2D

@onready var anglerfish = $"../Anglerfish" as Anglerfish
@onready var camera = $"../Camera2D"
@onready var light = $"../Light" as Light
@onready var fish_spawner = $"../FishSpawner" as FishSpawner
@onready var fullness_bar = $"../UILayer/Control/ProgressBar"
@onready var score_text = $"../UILayer/Control/Score"
@onready var game_over = $"../UILayer/Control/GameOver" as Control
@onready var game_over_label = $"../UILayer/Control/GameOver/Label"

# When light gets cast out, it gets cast out in "stages"
var total_stages = 2
var curr_stage_index = 0
var init_anglerfish_pos = Vector2()
var score = 0
var is_game_over = false
var is_resetting = false
var is_eating = false

# Called when the node enters the scene tree for the first time.
func _ready():
	init_anglerfish_pos = anglerfish.global_position
	var x_pos = get_lure_position_for_stage(curr_stage_index)
	light.global_position.x = x_pos
	
	var hunger_timer = Timer.new()
	hunger_timer.wait_time = 1.0
	hunger_timer.one_shot = false
	hunger_timer.autostart = true
	var callable = Callable(self, "decrease_fullness_bar")
	hunger_timer.connect("timeout", callable)
	add_child(hunger_timer)


func decrease_fullness_bar():
	fullness_bar.value -= 1
	if fullness_bar.value == 0: 
		is_game_over = true
		game_over.visible = true
		game_over_label.text = "Your score: " + str(score)
		var tween = create_tween()
		tween.tween_property(game_over, "modulate:a", 1, 0.5)
		

func handle_game_over():
	game_over_label.text = "Your score: " + str(score)
	game_over.visible = true
	game_over.modulate = Color(1, 1, 1, 1)


func get_lure_position_for_stage(stage: int):
	var screen_size = get_viewport_rect().size
	var screen_width = screen_size.x / 1.25
	return (((stage * screen_width) / total_stages) + \
			(((stage + 1) * screen_width) / total_stages)) / 2


func _physics_process(delta):
	if Input.is_action_just_pressed("reel"):
		if !is_game_over:
			var fish = fish_spawner.fish_on_screen
			if fish != null and is_instance_valid(fish):
				if !fish.is_reeling and !fish.is_eaten:
					if fish.is_biting_lure:
						if curr_stage_index == total_stages - 1:
							is_eating = true
							fish.is_eaten = true
							var eat_tween = create_tween()
							var light_pos = light.global_position
							anglerfish.update_texture("res://Sprites/bite-1.png")
							eat_tween.tween_property(anglerfish, "global_position", Vector2(anglerfish.global_position.x - 200, anglerfish.global_position.y), 0.5)
							eat_tween.parallel().tween_property(light, "global_position", Vector2(light_pos.x, -200), 0.5) 
							eat_tween.finished.connect(on_fish_eat)
						else:
							fish.is_reeling = true
							var tween = create_tween()
							var new_x_pos = get_lure_position_for_stage(curr_stage_index + 1)
							curr_stage_index += 1
							tween.tween_property(light, "global_position", Vector2(new_x_pos, light.global_position.y), 1.5).set_ease(Tween.EASE_OUT)
							tween.finished.connect(fish.reel_complete)
					else:
						fish.escape(reset_after_escape)
	if Input.is_action_just_pressed("toggle_light_brightness"):
		var fish = fish_spawner.fish_on_screen
		if fish != null and is_instance_valid(fish):
			fish.escape(reset_after_escape)
		light.toggle_brightness_level()
	if Input.is_action_just_pressed("turn_off_light"):
		var fish = fish_spawner.fish_on_screen
		if fish != null and is_instance_valid(fish):
			fish.escape(reset_after_escape)
		light.toggle_off_on()


func is_light_off():
	return is_resetting or light.is_off or is_eating
	

func get_light_brightness() -> Light.Brightness:
	return light.curr_brightness_level


func on_fish_eat():
	anglerfish.update_texture("res://Sprites/bite-2.png")
	var fish = fish_spawner.fish_on_screen as Fish
	fish.visible = false
	var reset_tween = create_tween()
	var screen_size = get_viewport_rect().size
	is_resetting = true
	reset_tween.tween_property(anglerfish, "global_position", init_anglerfish_pos, 1).set_ease(Tween.EASE_OUT)
	reset_tween.finished.connect(reset_after_eating)
	
	# Large fish are worth more
	var score_to_add = 1 if fish.curr_fish_type == Fish.FishTypes.SMALL else 2
	score += score_to_add
	fullness_bar.value += 25 if fish.curr_fish_type == Fish.FishTypes.SMALL else 50
	score_text.text = "Score: " + str(score)
	

func reset_after_eating():
	var screen_size = get_viewport_rect().size
	var fish = fish_spawner.fish_on_screen as Fish
	fish.queue_free()
	var reset_light_tween = create_tween()
	curr_stage_index = 0
	var tween = create_tween()
	tween.tween_property(light, "global_position", Vector2(get_lure_position_for_stage(curr_stage_index), -200), 0.5)
	tween.tween_property(light, "global_position", Vector2(get_lure_position_for_stage(curr_stage_index), screen_size.y / 2), 0.5)
	tween.finished.connect(on_reset_complete)


func reset_after_escape():
	var reset_light_tween = create_tween()
	curr_stage_index = 0
	var light_pos = Vector2(get_lure_position_for_stage(curr_stage_index), light.global_position.y)
	reset_light_tween.tween_property(light, "global_position", light_pos, 1)
	reset_light_tween.finished.connect(on_reset_complete)
	

func on_reset_complete():
	anglerfish.update_texture("res://Sprites/neutral.png")
	is_resetting = false
	is_eating = false


func _on_button_pressed():
	get_tree().reload_current_scene()
