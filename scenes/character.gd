class_name VNCharacter extends Control


@export var dialog_box:PackedScene
@export var default_sprite:CompressedTexture2D
@export var tagged_sprites:Dictionary[String,CompressedTexture2D] # i dont think these do anything tbh

signal garbage_error



#func attr(attribute:String=""):
	#print ("Getting attribute " + attribute)
	#texture=tagged_sprites.get(attribute,default_sprite)
	# commented out cuz it probably doesnt interact with the current sprite system
	#   this code works to add the currently selected sprite/character expression
	#   to the properties inspector on the left


func snap (targ:Node): # Creates the "snap" command for writing, its a snap
	position=targ.position

func move(targ:Node, seconds:float=1, trans:Tween.TransitionType=Tween.TRANS_QUAD) ->Signal: # Creates "move", uses a tween motion
	var pos:Vector2=targ.position
	var tween = get_tree().create_tween()
	tween.tween_property (self, "position", pos, seconds).set_trans(Tween.TRANS_LINEAR)
	return tween.finished

func say(text: String, _tag:String="")->Signal:
	var d:DialogBox=dialog_box.instantiate()
	if ! d:
		print("Unknown dialog box configuration: " + str(dialog_box))
		return garbage_error
	d.dialog=text
	get_tree().root.add_child(d)
	return d. complete
