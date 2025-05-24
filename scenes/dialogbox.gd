class_name DialogBox extends RichTextLabel

#https://youtu.be/oN5VTIZjyb0 watch this video

@export var dialog:String="kms kms kms kms kms kms if this is running ouughh ill be mad":
	set(n):
		dialog=n
		reset_text()
var tween:Tween

signal complete

func _input(event: InputEvent) -> void:
	if ! is_node_ready():
		return
	if event is InputEventMouseButton and event.is_pressed():
		print ("Click!")
		advance()
func advance():
	if Tween:
		print ("kill that fucking tween NOW")
		tween.stop()
		tween=null
		%DialogBox.visible_ratio=1
		show_button()
	else:
		print("killing.....")
		self_destruct() # advancing kills tween if ongoing, and reveals all text
		
func self_destruct():
	get_parent().remove_child(self)
	complete.emit()
	queue_free()
	
func _ready() -> void:
	reset_text()
	
func reset_text(): # hides the text, tween reveals it, and then the tween is done
	
	if ! is_node_ready()	:
		return
	%DialogBox.text=dialog
	%DialogBox.visible_ratio=0	
	%AdvanceButton.visible = false
	
	if tween:
		tween.stop()
	tween = get_tree().create_tween()
	@warning_ignore("integer_division")
	tween.tween_property(%DialogBox, "visible_ratio", 1, (dialog.length() / 30) + 1).set_trans(Tween.TRANS_LINEAR)
	await tween.finished
	tween=null
	show_button()
	
func show_button(): # function for revealing the advance triangle button guy
	%AdvanceButton.visible = true
	
func _on_button_pressed() -> void: # advance when pressing the advance button (the fuckass triangle)
		print ("Manual Skip")
		advance()
