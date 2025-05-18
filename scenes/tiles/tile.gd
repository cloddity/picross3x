extends Button

signal tile_pressed
signal tile_hovered(tile: Node)

const UNIT_CONST = 36

var is_filled: bool = false
var is_marked_fill: bool = false
var is_marked_x: bool = false
var grid_position: Vector2i

func _ready():
	text = ""
	toggle_mode = false
	focus_mode = Control.FOCUS_NONE
	custom_minimum_size = Vector2(UNIT_CONST, UNIT_CONST)
	
	mouse_filter = Control.MOUSE_FILTER_PASS
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))

func _on_mouse_entered():
	emit_signal("tile_hovered", self)

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			toggle_fill()
			emit_signal("tile_pressed")
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			toggle_x()
			emit_signal("tile_pressed")

		emit_signal("tile_pressed")

func toggle_fill():
	if is_marked_fill:
		is_marked_fill = false
		text = ""
	else:
		is_marked_fill = true
		is_marked_x = false
		text = "■"
		#modulate = "WHITE"
		
#func toggle_fill_drag():
	#is_marked_fill = true
	#is_marked_x = false
	#text = "■"

func toggle_x():
	if is_marked_x:
		is_marked_x = false
		text = ""
	else:
		is_marked_x = true
		is_marked_fill = false
		text = "X"
