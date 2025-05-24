extends Control

signal import_requested(puzzle_data: Array)
signal random_requested()

@onready var import_text = $inputContainer/importText
@onready var import_button = $inputContainer/buttonContainer/importButton
@onready var random_button = $inputContainer/buttonContainer/randomButton

func _ready():
	import_button.pressed.connect(_on_import_pressed)
	random_button.pressed.connect(_on_random_pressed)

func _on_import_pressed():
	var input_text = import_text.text.strip_edges()
	var lines = input_text.split(",", false)

	if lines.is_empty():
		print("No input provided.")
		return

	var puzzle_data = []
	for line in lines:
		var row = []
		for char in line.strip_edges():
			row.append(1 if char == "1" else 0)
		puzzle_data.append(row)

	emit_signal("import_requested", puzzle_data)

func _on_random_pressed():
	emit_signal("random_requested")
