extends Button

signal tile_pressed
signal tile_hovered(tile: Node)

const UNIT_CONST = 36

var is_filled: bool = false
var is_marked: int = 0
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
	
func is_mouse_over() -> bool:
	return get_global_rect().has_point(get_viewport().get_mouse_position())

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			emit_signal("tile_pressed")

func toggle_fill():
	is_marked = 1
	text = "■"

func untoggle_fill():
	is_marked = 0
	text = ""
	
func toggle_x():
	is_marked = 2
	text = "X"

#func toggle_fill_drag():
	#is_marked_fill = true
	#is_marked_x = false
	#text = "■"
