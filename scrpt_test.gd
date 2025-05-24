class_name VN extends Node2D

const BEAT = preload("res://scenes/chara/beat.tscn") # load characters for scene
const SPIRIT = preload("res://scenes/chara/cosmicspirit.tscn")


#  
#  hello! this is a test for an allmighty script that can house all our
#  dialog and the code shit that moves around characters and whatnot.
#
#  the characters are literally just
#  two pngs i found on my computer lol
#
#  im aiming for being able to put in all the data for an entire scene into 
#  a file like this. Then when we run the game, it can chain however many 
#  of these scripts together as we'd like. from there, I want to figure out 
#  an organization solution for these scenes and how they interact just so 
#  any amount of branching path is managable.
#
#     -rhp
#

func _ready():
	
	var b:VNCharacter=BEAT.instantiate() # adds the characters to the scene
	var s:VNCharacter=SPIRIT.instantiate()
	add_child(b) # this chunk could probably be put into a character master list
	add_child(s) # and just loaded at the top? maybe?
	
	b.snap(%offright) # start beat offscreen to the right
	s.snap(%offleft) # start cosmic spirit offscreen to the left
	await wait(1.5)
	
	b.move(%farright, 2)
	b.move(%right, 1.5)
	b.move(%center, 1)
	await wait(0.25)
	b.flip_h=true #flips beat
	b.move(%farleft, 0.5)
	
func wait(seconds:float=1) -> Signal:
	return get_tree().create_timer(seconds).timeout
	;
