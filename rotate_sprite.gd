extends Sprite

var sprite_rotation = 0
var click_pos = Vector2.ZERO
var move_delta = Vector2.ZERO

var is_dragging = false

func _input(event):
	# second condition tests whether the click occured within the area of the sprite
	if Input.is_action_just_pressed("left_mouse") && get_rect().has_point(to_local(event.position)):
		print("clicked")
		click_pos = event.position
		is_dragging = true
	elif Input.is_action_just_released("left_mouse"):
		print("unclicked")
		is_dragging = false
		sprite_rotation = self.rotation_degrees
	
	if is_dragging:
#		move_delta = click_pos - event.position
		var center = position
		var p0 = click_pos
		var p1 = event.position
		
		# calculate the angle to add to the sprite's rotation
		var add_rotation = angle_diff(center, p0, p1)
		
		#if the rotation is negative, convert add_rotation to negative
		if((p0.x > p1.x && p1.y < center.y) || (p0.x < p1.x && p1.y > center.y)): add_rotation *= -1
		
		self.rotation_degrees = add_rotation + sprite_rotation
#		self.rotation_degrees = -move_delta.x + sprite_rotation
		

# calculate the angle between 2 points about a center point
func angle_diff(center : Vector2, p0 : Vector2, p1 : Vector2):
	# calculate (side length)^2's
	var center_p0_sqr = length_sqr(center, p0)
	var center_p1_sqr = length_sqr(center, p1)
	var p0_p1_sqr = length_sqr(p0, p1)
	
	# derive side lengths from (side length)^2's
	var center_p0 = sqrt(center_p0_sqr)
	var center_p1 = sqrt(center_p1_sqr)
	var p0_p1 = sqrt(p0_p1_sqr)
	
	# godot uses radians, so calculate angle radians
	var angle_rad = acos((center_p0_sqr + center_p1_sqr - p0_p1_sqr)/(2*center_p0*center_p1))
	
	# convert to degrees before return
	return rad2deg(angle_rad)

#calculate the distance between 2 points squared
func length_sqr(A : Vector2, B : Vector2):
	var x_diff = (A.x - B.x)
	var y_diff = (A.y - B.y)
	return (x_diff * x_diff) + (y_diff * y_diff)
	
func _ready():
	pass




