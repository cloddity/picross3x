# vn_refrect.gd
# this file is for finding each position reference square (offleft, center, farRight, etc) and then making it so any other file can just load and match these positions as needed
# this will allow characters to go to places on the screen as needed during VN segments
#
# this script is loaded globally for now, since I want other scripts to be able to access the positions of these reference rectangles
# !!!! access positions outside this script as `refrectpos.left_hpos`, `refrectpos.center_hpos`, etc !!!!
# im pretty sure any variable in this specific script is global in the same way with 'refrectpos.' (reference rectangle position)
# 
# todo: make sure the actual reference rectangles themselves stay in position upon resizing/stretching game window
#

extends Control

var offLeft_hpos := 0.0
var farLeft_hpos := 0.0
var left_hpos := 0.0
var center_hpos := 0.0
var right_hpos := 0.0
var farRight_hpos := 0.0
var offRight_hpos := 0.0
# yeah, these could probably get condensed somehow. I dont mind keeping them seperate for
# for now because i doubt we'll need more than these positions to point to on screen for characters
var offLeft: ReferenceRect
var farLeft: ReferenceRect
var left: ReferenceRect
var center: ReferenceRect
var right: ReferenceRect
var farRight: ReferenceRect
var offRight: ReferenceRect

func _ready() -> void:
	# gets the reference rectangles/their nodes
	offLeft = get_node_or_null("offLeft") as ReferenceRect
	farLeft = get_node_or_null("farLeft") as ReferenceRect
	left = get_node_or_null("left") as ReferenceRect
	center = get_node_or_null("center") as ReferenceRect
	right = get_node_or_null("right") as ReferenceRect
	farRight = get_node_or_null("farRight") as ReferenceRect
	offRight = get_node_or_null("offRight") as ReferenceRect
	
	update_positions() # initial position update
	connect_rectsignals() # connects signals for updating
	
func get_hpos(rect: ReferenceRect) -> float: # for getting the h position of any rectangle
	if rect == null:
		push_warning("Attempted to get position of null ReferenceRect")
		return 0.0

	if not rect.is_inside_tree():
		push_warning("ReferenceRect not in scene tree")
		return 0.0
	
	await get_tree().process_frame
	return rect.global_position.x + (rect.size.x / 2.0) # takes the width, halves it, and gets the center position
	
func update_positions() -> void:
	# gets the horizontal pos of the node and then assigns it to center_hpos, left_hpos, etc
	if offLeft: offLeft_hpos = await get_hpos(offLeft)
	if farLeft: farLeft_hpos = await get_hpos(farLeft)
	if left: left_hpos = await get_hpos(left)
	if center: center_hpos = await get_hpos(center)
	if right: right_hpos = await get_hpos(right)
	if farRight: farRight_hpos = await get_hpos(farRight)
	if offRight: offRight_hpos = await get_hpos(offRight)
	
	# Debug output, remove the hashtag to fill up the output panel lol
	#print_debug("Left: ", left_hpos," Center: ", center_hpos," Right: ", right_hpos)
	
func connect_rectsignals() -> void: # allows the signals to be updated? i think?
	var timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(update_positions)
	timer.start(2)  # Check every 2 seconds
