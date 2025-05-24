extends Control

@onready var board = $Board

func _ready():
	board.start_game()
