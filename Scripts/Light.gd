class_name Light
extends Node2D

enum Brightness { LOW, HIGH }
var curr_brightness_level = Brightness.LOW
var is_off = false

@onready var glow = $Glow as Sprite2D
@onready var sprite = $Sprite2D as Sprite2D

func _ready():
	set_brightness(Brightness.LOW)
	
func toggle_brightness_level():
	if !is_off:
		var new_brightness = Brightness.HIGH if curr_brightness_level == Brightness.LOW else Brightness.LOW
		set_brightness(new_brightness)

func set_brightness(brightness: Brightness):
	curr_brightness_level = brightness
	if (brightness == Brightness.LOW):
		glow.scale = Vector2(2, 2)
		glow.modulate = Color(1, 1, 1, 0.25)
		sprite.modulate = Color(1, 1, 1, 0.75)
	elif (brightness == Brightness.HIGH):
		glow.scale = Vector2(3, 3)
		glow.modulate = Color(1, 1, 1, 0.5)
		sprite.modulate = Color(1, 1, 1, 1)

func toggle_off_on():
	if is_off:
		set_brightness(curr_brightness_level)
	else:
		glow.scale = Vector2(0, 0)
		sprite.modulate = Color(0, 0, 0, 0.5)
	is_off = !is_off
