extends Node2D

@onready var anglerfish = $"../Anglerfish"
@onready var light = $"../Light"
@onready var camera = $"../Camera2D"

# When light gets cast out, it gets cast out in "stages"
var total_stages = 2
var curr_stage_index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	position_lure()

func position_lure():
	var screen_size = get_viewport_rect().size
	var screen_width = screen_size.x
	var x_pos = (((curr_stage_index * screen_width) / total_stages) + \
			(((curr_stage_index + 1) * screen_width) / total_stages)) / 2
	light.global_position.x = x_pos


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
