class_name Fish
extends Node2D

@onready var light = get_node("/root/Main/Light") as Node2D
@onready var sprite = $Sprite2D
@onready var player_controller = get_node("/root/Main/PlayerController") as PlayerController

const MOVE_SPEED = 100
const ESCAPE_SPEED = 300
const CHASING_LURE_SPEED = 275

var is_investigating_lure = false
var is_biting_lure = false
var is_reeling = false
var is_escaping = false
var is_eaten = false

var escape_dest = null
var escape_timer: Timer = null
var bite_lure_timer: Timer = null
var num_nibbles_before_bite: int = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	var screen_size = get_viewport_rect().size
	var x_pos = 0
	var y_pos = randi_range(0, screen_size.y)
	global_position = Vector2(x_pos, y_pos)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if is_eaten:
		if escape_timer != null:
			escape_timer.stop() 
			escape_timer.queue_free()
		return
	if !is_investigating_lure:
		var dist_to_target = global_position.distance_to(light.global_position)
		if dist_to_target > 40:
			var dir = (light.global_position - global_position).normalized()
			sprite.flip_h = dir.x < 0
			translate(dir * delta * MOVE_SPEED)
		else:
			is_investigating_lure = true
			num_nibbles_before_bite = randi_range(1, 4)
			start_biting_lure()
	if is_reeling:
		if escape_timer != null:
			escape_timer.stop() 
			escape_timer.queue_free()	
		var dist_to_target = global_position.distance_to(light.global_position)
		if dist_to_target > 40:
			var dir = (light.global_position - global_position).normalized()
			sprite.flip_h = dir.x < 0
			translate(dir * delta * CHASING_LURE_SPEED)


func start_biting_lure():
	bite_lure_timer = Timer.new()
	bite_lure_timer.one_shot = true
	bite_lure_timer.autostart = true
	bite_lure_timer.wait_time = randi_range(1, 3)
	var callable = Callable(self, "bite_or_nibble").bind(bite_lure_timer)
	bite_lure_timer.connect("timeout", callable)
	add_child(bite_lure_timer)
	
	
func bite_or_nibble(timer: Timer):
	timer.queue_free()
	if num_nibbles_before_bite == 0:
		var tween = create_tween()
		tween.tween_property(self, "global_position", light.global_position, 0.25)
		is_biting_lure = true
		
		# Set a timer window in which the player must reel in before the fish escapes
		escape_timer = Timer.new()
		escape_timer.autostart = true
		escape_timer.one_shot = true
		escape_timer.wait_time = 1.0
		var callable = Callable(self, "escape").bind(player_controller.reset_after_escape)
		escape_timer.connect("timeout", callable)
		add_child(escape_timer)
	else:
		num_nibbles_before_bite -= 1
		var curr_position = Vector2(global_position.x, global_position.y)
		var tween = create_tween()
		tween.set_loops(1)
		tween.tween_property(self, "global_position", light.global_position, 0.25)
		tween.tween_property(self, "global_position", curr_position, 0.5)
		tween.finished.connect(start_biting_lure)


func escape(callable: Callable):
	if !is_escaping:
		is_escaping = true
		if bite_lure_timer != null and is_instance_valid(bite_lure_timer):
			bite_lure_timer.stop()
			bite_lure_timer.queue_free()
		is_biting_lure = false
		var screen_size = get_viewport_rect().size
		var x_pos = 0
		var y_pos = randi_range(0, screen_size.y)
		var dir = (Vector2(x_pos, y_pos) - global_position).normalized()
		var escape_dest = global_position + (dir * 100)
		var escape_tween = create_tween()
		escape_tween.tween_property(self, "global_position", escape_dest, 0.5)
		escape_tween.parallel().tween_property(self, "modulate:a", 0, 0.5)
		var new_callable = Callable(self, "on_escape_complete").bind(callable)
		escape_tween.finished.connect(new_callable)
		
		
func on_escape_complete(callable: Callable):
	callable.call()
	queue_free()
	

func reel_complete():
	is_biting_lure = false
	is_reeling = false
	is_investigating_lure = false
	
