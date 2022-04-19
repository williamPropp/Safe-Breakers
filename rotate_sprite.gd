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
		move_delta = click_pos - event.position
		self.rotation_degrees = -move_delta.x + sprite_rotation
	
#func _process(delta):
#	if is_dragging:
#		self.rotation_degrees = -move_delta.x + sprite_rotation
