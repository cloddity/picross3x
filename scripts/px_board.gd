extends VBoxContainer

const TILE_SCENE = preload("res://scenes/picross/tiles/tile.tscn")
@export var puzzle_height := 10
@export var puzzle_width := 10

var unit: int = preload("res://scripts/constants.gd").UNIT_CONST
var UNIT_CONST: int = int((1 - (0.06 * (puzzle_height - 5))) * unit)
var MARGIN_CONST: int = int(puzzle_width / 2) + 1

@onready var puzzle_container = $puzzleContainer
@onready var input_container = $UI/inputContainer
@onready var puzzle_grid = $puzzleContainer/rightSide/puzzleGrid
@onready var row_clues_box = $puzzleContainer/leftSide/rowClues
@onready var top_clues_box = $puzzleContainer/rightSide/colClues
@onready var top_left_filler = $puzzleContainer/leftSide/topLeftFiller
@onready var import_input = $UI/inputContainer/importText
@onready var import_button = $UI/inputContainer/buttonContainer/importButton
@onready var random_button = $UI/inputContainer/buttonContainer/randomButton
@onready var top_filler = $puzzleContainer/rightSide/topFiller
@onready var ui = $UI

var puzzle := []
var row_clues := []
var col_clues := []

var is_dragging := false
var drag_start_tile = null
var direction = null
var selected_rc = null
var selected_fx = null

func start_pxgame(): # renamed to be more specific to px
	generate_random_puzzle(puzzle_width, puzzle_height)
	initialize_puzzle()
	
	ui.import_requested.connect(_on_import)
	ui.random_requested.connect(_on_random)
	
	#print("Tile min size:", custom_minimum_size)
	#print("Tile actual size:", size)
	
	var target_width = puzzle_container.size.x
	input_container.position.x = UNIT_CONST * MARGIN_CONST
	print(target_width)
	
	var grid_max_size = 60
	puzzle_grid.custom_minimum_size = Vector2(grid_max_size, grid_max_size)
	puzzle_grid.size_flags_horizontal = Control.SIZE_FILL
	puzzle_grid.size_flags_vertical = Control.SIZE_FILL

func set_tile():
	is_dragging = true
	direction = null
	selected_rc = null
	drag_start_tile = null
	for tile in puzzle_grid.get_children():
		if tile.is_mouse_over():
			_on_tile_hovered(tile)
			break

func mark_tile(tile):
	if selected_fx == 1:
		tile.toggle_fill()
		print("f")
	elif selected_fx == 2:
		tile.toggle_x()
		print("x")
	
func _unhandled_input(event):
	#print("unhandled")
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				selected_fx = 1
				set_tile()
			else:
				is_dragging = false
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				selected_fx = 2
				set_tile()
			else:
				is_dragging = false

func _on_tile_hovered(tile):
	if not is_dragging:
		return

	if drag_start_tile == null:
		drag_start_tile = {
			"grid_position": tile.grid_position,
			"is_marked": tile.is_marked,
		}
		if tile.is_marked == 0:
			if selected_fx == 1:
				tile.toggle_fill()
			elif selected_fx == 2:
				tile.toggle_x()
		elif tile.is_marked != 0:
			tile.untoggle_fill()
		print("initialized:", drag_start_tile.grid_position, " ", drag_start_tile.is_marked)
		return

	var dx = tile.grid_position.x - drag_start_tile["grid_position"].x
	var dy = tile.grid_position.y - drag_start_tile["grid_position"].y

	if dx != 0 and dy != 0:
		return 
	
	if drag_start_tile["grid_position"] == tile.grid_position:
		return
		
	if dx != 0 and direction == null:
		direction = 0
		selected_rc = drag_start_tile["grid_position"].y
	elif dy != 0 and direction == null:
		direction = 1
		selected_rc = drag_start_tile["grid_position"].x

	if direction == 0 and tile.grid_position.y == drag_start_tile["grid_position"].y:
		if drag_start_tile["is_marked"] == 0 and tile.is_marked == 0:
			mark_tile(tile)
		elif drag_start_tile["is_marked"] != 0 and tile.is_marked != 0:
			if drag_start_tile["is_marked"] == tile.is_marked:
				tile.untoggle_fill()
				print("u1")
	elif direction == 1 and tile.grid_position.x == drag_start_tile["grid_position"].x:
		if drag_start_tile["is_marked"] == 0 and tile.is_marked == 0:
			mark_tile(tile)
		elif drag_start_tile["is_marked"] != 0 and tile.is_marked != 0:
			if drag_start_tile["is_marked"] == tile.is_marked:
				tile.untoggle_fill()
				print("u2")
			
	print(direction, " ", selected_rc, "dx", dx, "dy", dy)


func _in_range(val, a, b):
	return val >= min(a, b) and val <= max(a, b)

	
func adjust_top_left_filler():
	var max_col_clue_height = 0
	var max_row_clue_width = 0

	for vbox in top_clues_box.get_children():
		max_col_clue_height = max(max_col_clue_height, vbox.get_child_count())

	for hbox in row_clues_box.get_children():
		max_row_clue_width = max(max_row_clue_width, hbox.get_child_count())

	var filler_size = Vector2(MARGIN_CONST * UNIT_CONST, MARGIN_CONST * UNIT_CONST)
	var top_filler_size = Vector2(0, (MARGIN_CONST - max_col_clue_height + 1) * UNIT_CONST)

	top_left_filler.custom_minimum_size = filler_size
	top_filler.custom_minimum_size = top_filler_size
	top_filler.size_flags_horizontal = 0

func generate_random_puzzle(x: int, y: int):
	puzzle.clear()
	for _i in range(y):
		var row = []
		for _j in range(x):
			row.append(randi() % 2)
		puzzle.append(row)

# logic: given puzzle as binary rows (00,00), occupy row_clues and col_clues with lists of clues for each
func generate_clues():
	row_clues = []
	col_clues = []
	for row in puzzle:
		row_clues.append(_generate_clue_line(row))
	for col in range(puzzle_width):
		var column = []
		for row in range(puzzle_height):
			column.append(puzzle[row][col])
		col_clues.append(_generate_clue_line(column))

# logic: group a row or column of binary values
func _generate_clue_line(line: Array) -> Array:
	var clues = []
	var count = 0
	for val in line:
		if val == 1:
			count += 1
		elif count > 0:
			clues.append(count)
			count = 0
	if count > 0:
		clues.append(count)
	return clues if clues.size() > 0 else [0]

# render: 
func populate_clue_labels():
	for child in row_clues_box.get_children():
		child.queue_free()

	for child in top_clues_box.get_children():
		child.queue_free()

	for clues in row_clues:
		var hbox = HBoxContainer.new()
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var spacer = Control.new()
		spacer.size_flags_horizontal = Control.SIZE_EXPAND
		hbox.add_child(spacer)
		
		for num in clues:
			var label = Label.new()
			label.text = str(num)
			label.custom_minimum_size = Vector2(UNIT_CONST, UNIT_CONST)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			hbox.add_child(label)
		row_clues_box.add_child(hbox)

	for clues in col_clues:
		var vbox = VBoxContainer.new()
		vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL

		var spacer = Control.new()
		spacer.size_flags_vertical = Control.SIZE_EXPAND
		vbox.add_child(spacer)

		for num in clues:
			var label = Label.new()
			label.text = str(num)
			label.custom_minimum_size = Vector2(UNIT_CONST, UNIT_CONST)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			vbox.add_child(label)

		top_clues_box.add_child(vbox)

func populate_puzzle_grid():
	for child in puzzle_grid.get_children():
		child.queue_free()
	
	puzzle_grid.columns = puzzle_width
	for y in puzzle_height:
		for x in puzzle_width:
			var tile = TILE_SCENE.instantiate()
			tile.UNIT_CONST = UNIT_CONST
			tile.is_filled = puzzle[y][x] == 1
			tile.connect("tile_pressed", self.check_solution)
			puzzle_grid.add_child(tile)
			
			tile.grid_position = Vector2i(x, y)
			tile.connect("tile_hovered", Callable(self, "_on_tile_hovered"))
			
			tile.custom_minimum_size = Vector2(UNIT_CONST, UNIT_CONST)
			tile.set_anchors_preset(Control.PRESET_CENTER)
			tile.set_size(Vector2(UNIT_CONST, UNIT_CONST))

			tile.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			tile.size_flags_vertical = Control.SIZE_SHRINK_CENTER

func check_solution():
	var all_correct = true
	for tile in puzzle_grid.get_children():
		if tile.is_filled:
			if tile.is_marked != 1:
				all_correct = false
				break
		else:
			if tile.is_marked == 1:
				all_correct = false
				break
				
	if all_correct:
		print("solved")
		
func initialize_puzzle():
	generate_clues()
	populate_clue_labels()
	populate_puzzle_grid()
	await get_tree().process_frame
	adjust_top_left_filler()
	
func _on_import(puzzle_data: Array):
	puzzle = puzzle_data
	puzzle_height = puzzle.size()
	puzzle_width = puzzle[0].size() if puzzle_height > 0 else 0
	initialize_puzzle()

func _on_random():
	print("Generating random puzzle of size:", puzzle_width, puzzle_height)
	generate_random_puzzle(puzzle_width, puzzle_height)
	initialize_puzzle()
