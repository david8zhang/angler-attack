extends ProgressBar

var fill_box: StyleBoxFlat

# Called when the node enters the scene tree for the first time.
func _ready():
	fill_box = StyleBoxFlat.new()
	var background = StyleBoxFlat.new()
	background.bg_color = Color("#444444")
	self.add_theme_stylebox_override("fill", fill_box)
	self.add_theme_stylebox_override("background", background)
	fill_box.bg_color = Color("#2ecc71")


func _on_value_changed(value):
	if value < 25:
		fill_box.bg_color = Color("#c0392b")
	elif value < 50:
		fill_box.bg_color = Color("#f1c40f")
	else:
		fill_box.bg_color = Color("#2ecc71")
		
