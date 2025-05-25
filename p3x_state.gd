# state machine setup, im hoping this sort of setup is best in my new attempt at jamming together picross and vn gameplay lol
# This p3x_state.gd controls the states the game can be in within game.tscn
class_name GameState
extends Node



# These are the possible states for the entire overal game to be in. For now, its just gonna be play picross or play porn
var state_machine = '$state_machine'

# using _delta with the _ to stop the unused variable warning
#func _ready() -> void:
#	state_machine.init(self)
