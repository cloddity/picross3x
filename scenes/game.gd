extends Control

const TILE_SCENE = preload("res://scenes/tiles/Tile.tscn")

@onready var puzzle_grid = $MarginContainer/HBoxContainer/rightSide/puzzleGrid
@onready var row_clues_box = $MarginContainer/HBoxContainer/leftSide/rowClues
@onready var top_clues_box = $MarginContainer/HBoxContainer/rightSide/colClues

var puzzle_size := 5
var puzzle := []
var row_clues := []
var col_clues := []

func _ready():
	generate_random_puzzle(puzzle_size)
	generate_clues()
	populate_clue_labels()
	populate_puzzle_grid()

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
		for num in clues:
			var label = Label.new()
			label.text = str(num)
			label.custom_minimum_size = Vector2(48, 48)
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
			label.custom_minimum_size = Vector2(48, 48)
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
		print("Puzzle solved!")
	else:
		print("Still incorrect.")
