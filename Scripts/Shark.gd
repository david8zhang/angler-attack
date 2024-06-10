class_name Shark
extends RigidBody2D

var is_aggro = false
var is_attacking = false
@onready var player_controller = get_node("/root/Main/PlayerController") as PlayerController
@onready var sprite = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var screen_size = get_viewport_rect().size
	var y_pos = randi_range(0, screen_size.y / 2)
	var x_pos = 0
	global_position = Vector2(x_pos, y_pos)
	
	var aggro_timer = Timer.new()
	aggro_timer.autostart = true
	aggro_timer.one_shot = true
	aggro_timer.wait_time = 3.0
	var callable = Callable(self, "enable_aggro").bind(aggro_timer)
	aggro_timer.connect("timeout", callable)
	add_child(aggro_timer)
	linear_velocity = Vector2(200, 0)
	
	
func enable_aggro(timer: Timer):
	print("enabling aggro...")
	timer.queue_free()
	is_aggro = true

func _process(delta):
	var screen_size = get_viewport_rect().size
	if global_position.x > screen_size.x + 50:
		queue_free()
		
	if is_aggro:
		if !player_controller.is_light_off():
			if !is_attacking:
				is_attacking = true
				start_attack()
				
				
func start_attack():
	print("starting attack!")
	var tween = create_tween()
	tween.tween_property(self, "linear_velocity", Vector2(0, 0), 0.5)
	tween.finished.connect(charge_toward_screen)
	

func charge_toward_screen():
	var screen_size = get_viewport_rect().size
	sprite.texture = load("res://Sprites/shark-attack-2.png")
	var tween = create_tween()	
	tween.tween_property(sprite, "scale", Vector2(1, 1), 1.0)
	tween.parallel().tween_property(sprite, "modulate", Color(1, 1, 1, 1), 1.0)
	tween.parallel().tween_property(self, "global_position", Vector2(screen_size.x / 2, screen_size.y / 2), 1.0)
	tween.finished.connect(handle_game_over)


func handle_game_over():
	player_controller.handle_game_over()
