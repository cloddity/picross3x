extends Button
signal tile_pressed

var is_filled := false
var is_clicked := false

func _ready():
	text = "" 

func _pressed():
	if text == "■" or text == "X":
		text = ""
		modulate = "WHITE"
	else:
		if is_filled:
			text = "■"
			modulate = "GREEN"
		else:
			text = "X"
			modulate = "RED"

	emit_signal("tile_pressed")
