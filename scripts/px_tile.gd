extends TextureButton

signal tile_pressed
signal tile_hovered(tile: Node)

const UNIT_CONST = 36

var pxtile_empty = preload("res://img/sqr_black.png")
var pxtile_filled = preload("res://img/sqr_white.png")
var pxtile_cross = preload("res://img/sqr_cross.png")

var is_filled: bool = false
var is_marked: int = 0
var grid_position: Vector2i

func _ready():
	texture_normal = pxtile_empty
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


func untoggle_fill():
	is_marked = 0
	texture_normal = pxtile_empty

	
func toggle_fill():
	is_marked = 1
	texture_normal = pxtile_filled

	
func toggle_x():
	is_marked = 2
	texture_normal = pxtile_cross
