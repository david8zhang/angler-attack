extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "modulate:a", 0, 1)
	tween.tween_property(self, "modulate:a", 1, 1)
