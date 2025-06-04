extends Control

@onready var board = $Board

func _ready():
	await get_tree().process_frame
	board.start_pxgame()
