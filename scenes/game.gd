extends Control

const TILE_SCENE = preload("res://scenes/tiles/Tile.tscn")
const UNIT_CONST = 36
const MARGIN_CONST = 3

@onready var puzzle_container = $MarginContainer/picrossContainer/puzzleContainer
@onready var input_container = $MarginContainer/picrossContainer/UI/inputContainer
@onready var puzzle_grid = $MarginContainer/picrossContainer/puzzleContainer/rightSide/puzzleGrid
@onready var row_clues_box = $MarginContainer/picrossContainer/puzzleContainer/leftSide/rowClues
@onready var top_clues_box = $MarginContainer/picrossContainer/puzzleContainer/rightSide/colClues
@onready var top_left_filler = $MarginContainer/picrossContainer/puzzleContainer/leftSide/topLeftFiller
@onready var import_input = $MarginContainer/picrossContainer/UI/inputContainer/importText
@onready var import_button = $MarginContainer/picrossContainer/UI/inputContainer/buttonContainer/importButton
@onready var random_button = $MarginContainer/picrossContainer/UI/inputContainer/buttonContainer/randomButton
@onready var top_filler = $MarginContainer/picrossContainer/puzzleContainer/rightSide/topFiller

var puzzle_size := 5
var puzzle := []
var row_clues := []
var col_clues := []

var is_dragging := false
var drag_start_tile: Node = null
var current_drag_line := []

func _ready():
	generate_random_puzzle(puzzle_size)
	initialize_puzzle()
	
	import_button.pressed.connect(on_import_button_pressed)
	random_button.pressed.connect(on_random_button_pressed)
	
	print("Tile min size:", custom_minimum_size)
	print("Tile actual size:", size)
	
	var target_width = puzzle_container.size.x
	input_container.position.x = UNIT_CONST * MARGIN_CONST
	print(target_width)
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start_tile = null
				current_drag_line.clear()
			else:
				for tile in current_drag_line:
					tile.toggle_fill() 
				current_drag_line.clear()
				is_dragging = false
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				is_dragging = true
				drag_start_tile = null
				current_drag_line.clear()
			else:
				for tile in current_drag_line:
					tile.toggle_x() 
				current_drag_line.clear()
				is_dragging = false

func _on_tile_hovered(tile):
	if not is_dragging:
		return

	if drag_start_tile == null:
		drag_start_tile = tile
		current_drag_line.append(tile)
		#tile.toggle_fill()
		return

	var dx = tile.grid_position.x - drag_start_tile.grid_position.x
	var dy = tile.grid_position.y - drag_start_tile.grid_position.y

	if dx != 0 and dy != 0:
		return 

	current_drag_line.clear()

	for other_tile in puzzle_grid.get_children():
		if not other_tile is Button:
			continue
		var pos = other_tile.grid_position
		if dx == 0 and pos.x == drag_start_tile.grid_position.x:
			if _in_range(pos.y, drag_start_tile.grid_position.y, tile.grid_position.y):
				current_drag_line.append(other_tile)
		elif dy == 0 and pos.y == drag_start_tile.grid_position.y:
			if _in_range(pos.x, drag_start_tile.grid_position.x, tile.grid_position.x):
				current_drag_line.append(other_tile)
				
	#print("Dragging over:", tile.grid_position)

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

func generate_random_puzzle(size: int):
	puzzle.clear()
	for _i in size:
		var row = []
		for _j in size:
			row.append(randi() % 2)
		puzzle.append(row)

func generate_clues():
	row_clues = []
	col_clues = []
	for row in puzzle:
		row_clues.append(_generate_clue_line(row))
	for col in range(puzzle_size):
		var column = []
		for row in range(puzzle_size):
			column.append(puzzle[row][col])
		col_clues.append(_generate_clue_line(column))

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
	
	puzzle_grid.columns = puzzle_size
	for y in puzzle_size:
		for x in puzzle_size:
			var tile = TILE_SCENE.instantiate()
			tile.is_filled = puzzle[y][x] == 1
			tile.connect("tile_pressed", self.check_solution)
			puzzle_grid.add_child(tile)
			
			tile.grid_position = Vector2i(x, y)
			tile.connect("tile_hovered", Callable(self, "_on_tile_hovered"))
			
func check_solution():
	var all_correct = true

	for tile in puzzle_grid.get_children():
		if tile.is_filled:
			if tile.text != "■":
				all_correct = false
				break
		else:
			if tile.text == "■":
				all_correct = false
				break

	if all_correct:
		print("solved")
		
func on_import_button_pressed():
	var input_text = import_input.text.strip_edges()
	var lines = input_text.split(",", false)

	if lines.is_empty():
		print("No input provided.")
		return

	puzzle_size = lines.size()
	puzzle.clear()

	for line in lines:
		var row = []
		for char in line.strip_edges():
			row.append(1 if char == "1" else 0)
		puzzle.append(row)
		
	initialize_puzzle()
	
func initialize_puzzle():
	generate_clues()
	populate_clue_labels()
	populate_puzzle_grid()
	adjust_top_left_filler()
	await get_tree().process_frame
	adjust_top_left_filler()
	
func on_random_button_pressed():
	generate_random_puzzle(puzzle_size)
	initialize_puzzle()
