extends Sprite

var click_pos = Vector2.ZERO
var dial_rotation = 0
var current_term_value = 0
var current_combo_term = 1
var combo_term1 = "00"
var combo_term2 = "00"
var combo_term3 = "00"

var is_dragging = false

func _ready():
#	OS.window_fullscreen = true
	pass

func _process(delta):
	pass

func _input(event):
	# tests whether a click occured within the area of the sprite
	if Input.is_action_just_pressed("left_mouse") && get_rect().has_point(to_local(event.position)):
		# update click_pos offset and is_dragging state
		click_pos = event.position
		is_dragging = true
	elif Input.is_action_just_released("left_mouse"):
		# update dial_rotation offset and is_dragging state
		dial_rotation = self.rotation_degrees
		is_dragging = false
	
	if is_dragging:
		# get points: c (center of the dial), p0 (initial click position), and p1 (current drag position)
		var c = position
		var p0 = click_pos
		var p1 = event.position
		
		# calculate the angle to add to the dial's rotation
		var add_rotation = angle_diff(c, p0, p1)
		
		# rotate the dial using the current dial_rotation as an offset
		self.rotation_degrees = add_rotation + dial_rotation
		
	
#	current_term_value = self.rotation_degrees / 3
	current_term_value = self.rotation_degrees	
	current_term_value = int( floor(current_term_value) )
	combo_term1 = str(current_term_value)
	update_combination()


# calculate the angle between 2 points about a center point
# c is the center of the dial, p0 is the initial click position, and p1 is the current drag position
func angle_diff(c : Vector2, p0 : Vector2, p1 : Vector2):
	# the first half of the expression is the angle in radians between p1 and the x axis
	# the second half of the expression is the angle offset in radians from the x axis, determined by p0
	var angle_delta_rad = atan2(p1.y - c.y, p1.x - c.x) - atan2(p0.y - c.y, p0.x - c.x)
	
	# convert to degrees before returning
	var angle_delta_deg = rad2deg(angle_delta_rad)
	
	# convert any angles above or below the range (0,359) to its corresponding angle in that range
	angle_delta_deg = ( (int(angle_delta_deg) % 360) + 360 ) % 360
	
	return angle_delta_deg

func update_combination():
	var term1 = get_node("../combo_term1")
	var term2 = get_node("../combo_term2")
	var term3 = get_node("../combo_term3")
	term1.text = combo_term1
	term2.text = combo_term2
	term3.text = combo_term3


