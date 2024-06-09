class_name PlayerController
extends Node2D

@onready var anglerfish = $"../Anglerfish"
@onready var light = $"../Light"
@onready var camera = $"../Camera2D"
@onready var fish_spawner = $"../FishSpawner" as FishSpawner

# When light gets cast out, it gets cast out in "stages"
var total_stages = 2
var curr_stage_index = 0
var init_anglerfish_pos

# Called when the node enters the scene tree for the first time.
func _ready():
	init_anglerfish_pos = anglerfish.global_position
	var x_pos = get_lure_position_for_stage(curr_stage_index)
	light.global_position.x = x_pos


func get_lure_position_for_stage(stage: int):
	var screen_size = get_viewport_rect().size
	var screen_width = screen_size.x
	return (((stage * screen_width) / total_stages) + \
			(((stage + 1) * screen_width) / total_stages)) / 2


func _physics_process(delta):
	if Input.is_action_just_pressed("reel"):
		var fish = fish_spawner.fish_on_screen as Fish
		if fish != null and is_instance_valid(fish):
			if fish.is_biting_lure:
				if curr_stage_index == total_stages - 1:
					fish.is_eaten = true
					var eat_tween = create_tween()
					eat_tween.tween_property(anglerfish, "global_position", light.global_position, 0.5)
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


func on_fish_eat():
	var fish = fish_spawner.fish_on_screen as Fish
	fish.visible = false
	var reset_tween = create_tween()
	var screen_size = get_viewport_rect().size
	reset_tween.tween_property(anglerfish, "global_position", init_anglerfish_pos, 1).set_ease(Tween.EASE_OUT)
	reset_tween.finished.connect(reset_after_eating)
	

func reset_after_eating():
	var fish = fish_spawner.fish_on_screen as Fish
	fish.queue_free()
	var reset_light_tween = create_tween()
	curr_stage_index = 0
	var light_pos = Vector2(get_lure_position_for_stage(curr_stage_index), light.global_position.y)
	reset_light_tween.tween_property(light, "global_position", light_pos, 1)


func reset_after_escape():
	var reset_light_tween = create_tween()
	curr_stage_index = 0
	var light_pos = Vector2(get_lure_position_for_stage(curr_stage_index), light.global_position.y)
	reset_light_tween.tween_property(light, "global_position", light_pos, 1)
